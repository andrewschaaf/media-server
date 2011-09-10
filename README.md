
# Redis
<pre>
file_data:TOKEN   --> data
item_tokens       --> LIST (ordered by created_at DESC)
item_info:TOKEN   --> HASH->JSON
                        file_token
                        created_at
                        completed_at
</pre>


# API
<pre>
POST /api/upload
  ...raw body...
  --> {file_token:"..."}

GET /api/get-file?file_token=...
  --> ...raw...

GET /api/search
  --> {
    items: [
      {item_token:"..."}
    ]
  }
</pre>



# Developing

* NodeJS 0.4.x
* <code>chromedriver</code> on your <code>PATH</code>
* Ruby 1.9.x (1.8.x might work)
* <code>npm install -g</code>
* <code>gem install selenium-webdriver</code>
* <code>cd media-server; npm install</code>

<pre>
cake dev    # watches the filesystem, compiles {coffee,sass}, restarts the server
</pre>
