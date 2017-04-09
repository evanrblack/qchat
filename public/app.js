(function() {
  var dashboard = new Vue({
    el: '#dashboard',
    data: {
      filter: '',
      contacts: [],
      contact: {},
      messages: []
    },
    computed: {
      filteredContacts: function() {
        return this.contacts.filter(function(c) {
          var lowercasedName = c.name.toLowerCase();
          if (lowercasedName.includes(this.filter.toLowerCase())) {
            return c;
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
