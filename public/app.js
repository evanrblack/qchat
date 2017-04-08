(function() {
  var contactList = new Vue({
    el: '#contact-list',
    data: {
      contacts: [],
      filter: 'Rob'
    },
    computed: {
      filteredContacts: function() {
        console.log(this);
        return this.contacts.filter(function(contact) {
          var lowercasedName = contact.name.toLowerCase();
          if (lowercasedName.includes(this.filter.toLowerCase())) {
            return contact;
          }
        }, this);
      }
    },
    created: function() {
      this.$http.get('/contacts').then(function(response) {
        console.log(response);
        this.contacts = response.body;
      });
    }
  });
})();
