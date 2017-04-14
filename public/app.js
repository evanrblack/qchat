var dashboard = (function() {
  new Vue({
    el: '#dashboard',
    data: {
      filter: '',
      contacts: {},
      newContact: { phone_number: '' },
      contact: { id: null },
      newMessage: { text: '' },
      eventSource: new EventSource('/stream')
    },
    computed: {
      contactPath: function() {
        return '/contacts/' + this.contact.id;
      }
    },
    methods: {
      getContacts: function() {
        this.$http.get('/contacts').then(function(response) {
          response.body.forEach(function(c) {
            this.$set(this.contacts, c.id, c);
          }, this);
        }, function(response) {
          alert('Unable to get contacts'); 
        });
      },
      filterContact: function(c) {
        var lowerCasedFilter = this.filter.toLowerCase();
        var concatenated = (c.first_name + ' ' + 
                            c.last_name + ' ' +
                            c.phone_number);
        var lowerCased = concatenated.toLowerCase();
        return lowerCased.includes(lowerCasedFilter);
      },
      getContact: function(id) {
        var path = '/contacts/' + id;
        this.$http.get(path).then(function(response) {
          this.contact = response.body;
          this.contacts[this.contact.id] = this.contact;
          this.getMessages();
        }, function(response) {
          alert('Unable to get contact');
        });
      },
      getMessages: function() {
        var path = '/contacts/' + this.contact.id + '/messages';
        this.$http.get(path).then(function(response){
          this.$set(this.contact, 'messages', response.body);
          this.scrollToBottom();
        }, function(response) {
          alert('Unable to get messages');
        });
      },
      addContact: function(event) {
        var path = '/contacts'
        var formData = new FormData(event.target);
        this.$http.post(path, formData).then(function(response) {
          var contact = response.body;
          this.getContact(contact.id);
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
          this.contact = response.body;
          this.contacts[this.contact.id] = this.contact;
          this.contact.messages = messages;
        }, function(response) {
          alert('Unable to update contact');
        });
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
      scrollToBottom: function() {
        setTimeout(function() {
          var container = document.querySelector('#message-scroll');
          container.scrollTop = container.scrollHeight;
        }, 300);
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
            // On that contact already
            if (vue.contact.id == contact.id) {
              vue.contact = contact
              vue.contacts[vue.contact.id] = vue.contact;
            } else {
              // Set up notification
              var name = 'Unknown';
              var message = contact.messages[contact.messages.length - 1];
              if (contact.first_name && contact.last_name) {
                name = contact.first_name + ' ' + contact.last_name;
              }
              var title = name + ' (' + contact.phone_number + ')';
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
    return new Notification(title, {body: body});
  }
}

if (document.getElementById('dashboard')) dashboard();
