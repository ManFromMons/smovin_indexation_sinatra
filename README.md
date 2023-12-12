

# rent_indexation_sinatra

A sample of a Sinatra API to pass the Indexation tests supplied as part of the challenge-master test.

Testing Sinatra installation: `ruby sa.rb` Starting the API: `rackup`

The API is accessible on `/api/v1/indexations.` It will accept POSTs on the above address only.      
POST the following JSON to the `/api/v1/indexations` endpoint:

`{
"start_date": "2010-09-01",
"signed_on": "2010-07-25",
"current_date": "2020-01-01",
"base_rent": "500",
"region": "brussels"
}`

`current_date` is optional, it can be used to prove the results match the supplied request, or for other historical data.
> It can be ommitted, in which case `today` is used

You will receive the following response:

    {
      "new_rent": 584.18, 
      "base_index": 112.74, 
      "current_index": 131.72
    } 

### Error Responses
If the external service is not available:

    {  "error": "[Base|Current} health-index cannot be calculated with 2021-12-01-1998: External service not available" }

If the supplied data does not resolve to a viable health-index from the service provider, for either of the indices, you will receive:

    {  "error": "[Base|Current] health-index cannot be calculated with 2021-12-01-1998: No data available" }

Badly formatted JSON on the body will give this response:

    {  "error": "Error occurred while parsing request parameters" }

Validation errors will follow this pattern:

    {
    "start_date": [ "invalid" ],
    "signed_on": [ "invalid" ]
    }


## Installing the API
Firstly:

`gh repo clone ManFromMons/rent_indexation_sinatra`

change to the created folder and run`bundle install`.

If there are problems, try:

`gem install Sinatra` `gem install Puma` `bundle install`

This is *all* that should be required, if `bundle install` failed.  You can also try:      
`gem install Rackup` though there are version incompatibility issue with Rackup and Sinatra's dependency on versions of Rack < 3.x.

> do this if there are rackup problems - caution - this might overwrite other installs

### Starting-up
To test your install of the API, the entry point, `sa.rb` to be run with `ruby sa.rb` should produce the following or similar:

`== Sinatra (v3.1.0) has taken the stage on 4567 for development with backup from Puma Puma starting in single mode... > * Puma version: 6.4.0 (ruby 3.2.2-p53) ("The Eagle of Durango") > *  Min threads: 0 > *  Max threads: 5 > *  Environment: development > *          PID: 98356 > * Listening on http://127.0.0.1:4567 > * Listening on http://[::1]:4567 Use Ctrl-C to stop`

The API is a modular Sinatra application, and as such is started with `rackup`.  It is configured to use Puma.      
You should receive similar output to the above if *rackup* is succesful.

> The API has CORS integration to allow any origin to reach`/api/v1/*` with `GET`requests to '/' and `POST` requests to '/indexations' only.  `GET` requests to '/indexations' are not allowed and POSTs to '/' the same

# What is the the repo
This is a modular Sinatra app.        
There is a gemfile:

gem 'date'    gem 'debase'        
gem 'json'        
gem 'net-http'        
gem 'puma'        
gem 'rack-cors'        
gem 'rack-unreloader'        
gem 'rubocop'        
gem 'sinatra'        
gem 'sinatra-contrib'

There is `config.ru` to configure Rack.

## Rack configuration
Rack is configured to use the `rack-unloader` gem.

> This has helped debugging speed.... 😐

> As has not using WSL2 - native Fedora is 1000% faster

There are two route mappings:

* `map '/' =>` the front-end
* `map '/api/v1' =>` the API

Each are contained in there own classes which are executed by Rack as `run IndexationFrontEnd` and `run IndexationAPI`.

> The unloader gem wraps these now, and it is the unloader that is executed

> Rack::Cors configuration is defined on a per-application basis.      
> There is no front-end in the project (as of writing)

## The API Implementation
The API is implemented in `indexation_api.rb`.      
This references these modules:

require './Indexation/indexation_http' require './Indexation/date_calculations'    require './Indexation/calculations'        
require './Indexation/validations'      
All logic is distributed amongst these modules - the API class only shapes the response from validation and calculation.

The calculations module `requires` `date_calculations` - this separation is simple file modularisation.    
The HTTP element of the calculation  is provided by `Proc.new` to the calculation module by the API class.
