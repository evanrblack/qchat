var dashboard = (function() {
  new Vue({
    el: '#dashboard',
    data: {
      textFilter: '',
      statusFilters: { unseen: 0 },
      contacts: [],
      newContact: { phone_number: '' },
      contact: {
        id: null,
        first_name: null,
        last_name: null,
        email: null,
        wedding_date: null,
        phone_number: null,
        lead_source: null,
        messages: [],
        unseen_messages_count: null,
      },
      newMessage: { text: '' },
      pendingMessages: 0,
      eventSource: new EventSource('/stream')
    },
    watch: {
      'contact.messages': function() {
        setTimeout(function() {
          var container = document.querySelector('#message-scroll');
          container.scrollTop = container.scrollHeight;
        }, 300);
      }
    },
    computed: {
      contactPath: function() {
        return `/contacts/${this.contact.id}`;
      },
      filteredContacts: function() {
        var contacts = this.contacts;
        var textFilter = this.textFilter.toLowerCase();
        // filter by text
        contacts = contacts.filter((c) => {
          var fullName = (`${c.first_name} ${c.last_name}`).toLowerCase();
          var phoneNumber = c.phone_number;
          var leadSource = (c.lead_source || '').toLowerCase();
          return fullName.includes(textFilter)
            || phoneNumber.includes(textFilter)
            || leadSource.includes(textFilter);
        });
        // filter by unseen
        if (this.statusFilters.unseen) {
          contacts = contacts.filter((c) => c.unseen_messages_count > 0);
        }
        return contacts;
      }
    },
    methods: {
      getContacts: function() {
        this.$http.get('/contacts').then(function(response) {
          response.body.forEach(function(c) {
            this.$set(this.contacts, this.contacts.length, c);
          }, this);
        }, function(response) {
          alert('Unable to get contacts'); 
        });
      },
      getContact: function(id) {
        var path = `/contacts/${id}`;
        this.$http.get(path).then(function(response) {
          var contact = this.contacts.find((c) => c.id == response.body.id);
          Object.assign(contact, response.body);
          this.contact = contact;
          this.getMessages();
        }, function(response) {
          alert('Unable to get contact');
        });
      },
      getMessages: function() {
        var path = `/contacts/${this.contact.id}/messages`;
        this.$http.get(path).then(function(response){
          this.$set(this.contact, 'messages', response.body);
        }, function(response) {
          alert('Unable to get messages');
        });
      },
      addContact: function(event) {
        var path = '/contacts'
        var formData = new FormData(event.target);
        this.$http.post(path, formData).then(function(response) {
          var contact = response.body;
          this.contacts.push(contact);
          this.getContact(contact.id);
          this.newContact.phone_number = '';
        }, function(response) {
          alert('Unable to add contact'); 
        });
      },
      updateContact: function(event) {
        var path = `/contacts/${this.contact.id}`;
        var formData = new FormData(event.target);
        this.$http.post(path, formData).then(function(response) {
          Object.assign(this.contact, response.body);
        }, function(response) {
          alert('Unable to update contact');
        });
      },
      deleteContact: function(event) {
        var path = `/contacts/${this.contact.id}`;
        if (confirm('Are you sure?')) {
          this.$http.delete(path).then(function(response) {
              this.contacts.splice(this.contacts.indexOf(this.contact), 1);
              this.contact = { id: null, messages: [] };
          }, function(response) {
            alert('Unable to delete contact');
          });
        }
      },
      addMessage: function(event) {
        var button = event.target.querySelector('button');
        button.disabled = true;
        var formData = new FormData(event.target);
        this.$http.post('/messages', formData).then(function(response) {
          this.contact.messages.push(response.body);
          this.newMessage.text = '';
          button.disabled = false;
        }, function(response) {
          alert('Unable to post message');
        });
      },
      updateMessage: function(message) {
        var messagePath = `/messages/${message.id}`;
        var messageData = { seen_at: new Date() };
        this.$http.patch(messagePath, messageData).then(function(response) {
          var updatedMessage = response.body;
          message.seen_at = updatedMessage.seen_at;
          this.contact.unseen_messages_count -= 1;
        }, function(response) {
          alert('Unable to update message'); 
        });
      },
      massText: function(event) {
        var text = prompt('Message to send to currently listed contacts:');
        this.filteredContacts.forEach((c) => {
          var to = c.phone_number;
          this.$http.post('/messages', { text: text, to: to }).then(function(response) {
            if (c == this.contact) this.contact.messages.push(response.body);
          });
        });
      }
    },
    created: function() {
      var vue = this;
      // Set up eventSource
      this.eventSource.onmessage = function(msg) {
        var data = JSON.parse(msg.data);
        var type = data.type;
        var content = data.content;

        var handlers = {
          'pending_messages': function(size) {
            vue.pendingMessages = size;
          },
          'new_message': function(contact) {
            var oldContact = vue.contacts.find((c) => c.id == contact.id);
            oldContact
              ? Object.assign(oldContact, contact)
              : vue.contacts.push(contact);
            if (vue.contact.id != contact.id) {
              // Set up notification
              var name = 'Unknown';
              var message = contact.messages[contact.messages.length - 1];
              if (contact.first_name || contact.last_name) {
                name = `${contact.first_name} ${contact.last_name}`;
              }
              var title = `${name} @ ${contact.phone_number}`;
              // Create notification
              var notification = notify(title, message.text);
              notification.onclick = function(event) {
                vue.getContact(contact.id);
                this.close();
              };
            }
          }
        }

        // Run the associated function
        handlers[type](content);
      }

      this.getContacts();
    }
  });
});

Notification.requestPermission();
function notify(title, body) {
  if (Notification.permission == 'granted') {
    return new Notification(title, { body: body, requireInteraction: false });
  }
}

if (document.getElementById('dashboard')) dashboard();
