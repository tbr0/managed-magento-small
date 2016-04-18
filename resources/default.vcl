vcl 4.0;
backend default {
    .host = "127.0.0.1";
    .port = "80";
}
backend master {
    .host = "192.168.3.1";
    .port = "80";
}
acl purge {
        "localhost";
}
sub vcl_recv {
    if (req.method == "PURGE") {
        if (!client.ip ~ purge) {
            return(synth(405, "Not allowed."));
        }
        return(hash);
    }
    if (req.restarts == 0) {
        if (req.http.x-forwarded-for) {
            set req.http.X-Forwarded-For =
            req.http.X-Forwarded-For + ", " + client.ip;
        } else {
            set req.http.X-Forwarded-For = client.ip;
        }
    }

    ### send certain requests to the master server.
    ### commenting out the "multipart/form-data" portion because I don't think it's necessary but keeping it around just incase.
    #if (req.url ~ "admin|captcha|export|install|contacts" || req.http.Content-Type ~ "multipart/form-data")
    if (req.url ~ "admin|captcha|export|install|contacts")
    {
        set req.backend_hint = master;
        return(pass);
    }
  
    ## always cache these images & static assets
    if (req.method == "GET" && req.url ~ "\.(css|js|gif|jpg|jpeg|bmp|png|ico|img|tga|wmf)$") {
        unset req.http.cookie;
        return(hash);
    }
  
    ### parse accept encoding rulesets to make it look nice
    if (req.http.Accept-Encoding) {
        if (req.http.Accept-Encoding ~ "gzip") {
            set req.http.Accept-Encoding = "gzip";
        } elsif (req.http.Accept-Encoding ~ "deflate") {
            set req.http.Accept-Encoding = "deflate";
        } else {
            # unkown algorithm
            unset req.http.Accept-Encoding;
        }
    }

    return(pass);
}

sub vcl_hash {
  ## Keep a separate cache for HTTP and HTTPS requests that come in over an SSL Terminated Load Balancer
    if (req.http.x-forwarded-proto) {
        hash_data(req.http.x-forwarded-proto);
    }
}

sub vcl_miss {
    if (req.method == "PURGE") {
        return (synth(404, "Not in cache."));
    }
    if (req.url ~ "^/[^?]+.(jpeg|jpg|png|gif|ico|js|css|txt|gz|zip|lzma|bz2|tgz|tbz|html|htm)(\?.|)$") {
        unset req.http.cookie;
        set req.url = regsub(req.url, "\?.$", "");
    }
}
sub vcl_backend_response {

    if (bereq.method == "PURGE") {
        set beresp.ttl = 0s;
    }
}
sub vcl_deliver {
    if (obj.hits > 0) {
            set resp.http.X-Cache = "HIT";
    } else {
            set resp.http.X-Cache = "MISS";
    }
    set resp.http.X-Server-Name = server.hostname;
}
