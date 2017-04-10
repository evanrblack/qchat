var dashboard = (function() {
  new Vue({
    el: '#dashboard',
    data: {
      filter: '',
      contacts: [],
      newContact: {},
      contact: {},
      eventSource: new EventSource('/stream')
    },
    computed: {
      filteredContacts: function() {
        return this.contacts.filter(function(c) {
          var concatenated = (c.first_name + c.last_name + c.phone_number)
          var lowercased = concatenated.toLowerCase();
          if (lowercased.includes(this.filter.toLowerCase())) {
            return c;
          }
        }, this);
      }
    },
    methods: { 
      getContact: function(id) {
        var index = this.contacts.findIndex(function(c) {
          return c.id == id;
        }, this);
        this.contact = this.contacts[index];
        
        // Get messages
        var path = '/contacts/' + id + '/messages'
        this.$http.get(path).then(function(response){
          this.contact.messages = response.body;
        }, function(response) {
          alert('Unable to get messages');
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
        }, function(response) {
          alert('Invalid number'); 
        });
      },
      updateContact: function(event) {
        var path = '/contacts/' + this.contact.id;
        var formData = new FormData(event.target);
        this.$http.post(path, formData).then(function(response) {
          this.contact = response.body;
        }, function(response) {
          alert('Unable to update contact');
        })
      }
    },
    created: function() {
      // Set up eventSource
      this.eventSource.onmessage = function(msg) {
        var data = JSON.parse(msg.data);
        var type = data.type;
        var content = data.content;

        console.log(type, content);

        var handlers = {
          'new_contact': function(contact) {
            notify('New contact: ' + contact.phone_number);
          },
          'new_message': function(contact) {
            notify('New message from ' + contact.name + ' (' + contact.phone_number + '): "' + contact.message + '"');
          }
        }

        handlers[type](msg);
      }

      // Get list of contacts
      this.$http.get('/contacts').then(function(response) {
        this.contacts = response.body;
      });
    }
  });
});

Notification.requestPermission();
function notify(msg) {
  if (Notification.permission == 'granted') {
    var notification = new Notification(msg);
  }
}

if (document.getElementById('dashboard')) dashboard();
