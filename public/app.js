var dashboard = (function() {
  new Vue({
    el: '#dashboard',
    data: {
      filter: '',
      contacts: [],
      newContact: { phone_number: '' },
      contact: { id: null },
      newMessage: { text: '' },
      eventSource: new EventSource('/stream')
    },
    methods: {
      resetContact: function(contact) {
        var index = this.contacts.findIndex(function(c) {
          return c.id == contact.id;
        }, this);
        this.contacts[index] = contact;
        return this.contacts[index];
      },
      filterContact: function(contact) {
        var concatenated = (contact.first_name + ' ' + 
                            contact.last_name + ' ' +
                            contact.phone_number);
        var lowercased = concatenated.toLowerCase();
        return lowercased.includes(this.filter.toLowerCase())
      },
      getContact: function(id) {
        // getContact
        var contactPath = '/contacts/' + id;
        this.$http.get(contactPath).then(function(response) {
          this.contact = this.resetContact(response.body);

          // Get messages
          var messagesPath = '/contacts/' + this.contact.id + '/messages';
          this.$http.get(messagesPath).then(function(response){
            this.$set(this.contact, 'messages', response.body);
            this.scrollToBottom();
          }, function(response) {
            alert('Unable to get messages');
          });
        }, function(response) {
          alert('Unable to get contact');
        });
      },
      contactPath: function(contact) {
        return '/contacts/' + contact.id;
      },
      addContact: function(event) {
        var formData = new FormData(event.target);
        this.$http.post('/contacts', formData).then(function(response) {
          this.contact = response.body;
          this.contacts.push(this.contact);
          this.newContact.phone_number = '';
        }, function(response) {
          alert('Unable to add contact'); 
        });
      },
      updateContact: function(event) {
        var path = '/contacts/' + this.contact.id;
        var formData = new FormData(event.target);
        this.$http.post(path, formData).then(function(response) {
          var messages = this.contact.messages;
          this.contact = this.resetContact(response.body);
          this.contact.messages = messages;
        }, function(response) {
          alert('Unable to update contact');
        });
      },
      addMessage: function(event) {
        var formData = new FormData(event.target);
        this.$http.post('/messages', formData).then(function(response) {
          // Should be handled by SSE, but immediate feedback is nice
          this.contact.messages.push({
            direction: 'out',
            text: this.newMessage.text
          });
          this.newMessage.text = '';
        }, function(response) {
          alert('Unable to post message');
        });
      },
      scrollToBottom: function() {
        setTimeout(function() {
          var container = document.querySelector('#message-scroll');
          container.scrollTop = container.scrollHeight;
        }, 200);
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
          'new_message': function(contact) {
            // Handles only inbound
            // On that contact already
            if (vue.contact.id == contact.id) {
              vue.contact = vue.resetContact(contact);
            } else {
              // Set up notification
              var name = 'Unknown';
              var message = contact.messages[contact.messages.length - 1];
              if (contact.first_name && contact.last_name) {
                name = contact.first_name + ' ' + contact.last_name;
              }
              var title = name + ' (' + contact.phone_number + ')';
              // Create notification
              var notification = notify(title, message.content);
              notification.onclick = function(event) {
                vue.contact = vue.resetContact(contact);
                vue.scrollToBottom();
                this.close();
              };
            }
          }
        }

        handlers[type](content);
      }

      // Get list of contacts
      this.$http.get('/contacts').then(function(response) {
        this.contacts = response.body;
      });
    }
  });
});

Notification.requestPermission();
function notify(title, body) {
  if (Notification.permission == 'granted') {
    return new Notification(title, {body: body});
  }
}

if (document.getElementById('dashboard')) dashboard();
