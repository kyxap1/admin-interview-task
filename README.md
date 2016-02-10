# task
Server administrator test

Write a script to generate nginx configuration files for domain names contained in attached file domains.list, with nginx acting as a proxy, and Apache as the backend server on localhost. Static content (jpg|jpeg|gif|png|ico|css|bmp|js|swf|avi|mp3|mpeg|wma|mpg|rar|zip) must be returned directly via nginx.

Configuration files must be generated in accordance with existing lists (see attached data files), with the following priority rules taken account:

1. ddos.list: If the requested domain name is contained in this file, then a static page and response code 503 must be returned.
2. suspend.list: If the requested domain name is contained in this file, then a static page with a message for user must be returned. Message locale is defined by the locale parameter specified in this file.
3. domains_ssl.list: If the requested domain name is contained in this file, then an HTTPS block must be added. If an additional parameter is available, then all requests to this domain via HTTP must be redirected to HTTPS.
4. domains.list: Main domain list for generating virtual hosts on the server.
Virtual host blocks must contain a minimum set of directives necessary for correct website operation.

You can use any programming language you prefer.

* Use of templates and includes is most welcome.
