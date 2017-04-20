server 'qchat.io', roles: %i[web app db], primary: true
set :default_env, {
  'RACK_ENV' => 'production'
}

