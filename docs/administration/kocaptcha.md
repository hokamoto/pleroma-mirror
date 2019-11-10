Pleroma uses the [kocaptcha](https://github.com/koto-bank/kocaptcha) service for captchas by default.

On the development machine, [install](https://www.rust-lang.org/tools/install) the toolchain for Rust language.

Build kocaptcha binary
```
$ git clone https://github.com/koto-bank/kocaptcha
$ cd kocaptcha
$ cargo build --release
```

A new binary called `kocaptcha` will be generated at target/release in the working directory.  
Move this binary to the server.
```
$ scp target/release/kocaptcha root@<my-pleroma-instance>:/tmp/
$ ssh root@<my-pleroma-instance>
# sudo -u pleroma /bin/bash
$ cp /tmp/kocaptcha ~/
```

To run the above binary, you will need glibc installed on the server.
```
# apt update
# apt install libc6
```

Create a systemd unit file for kocaptcha service which looks like this:
```
$ cat /etc/systemd/system/kocaptcha.service
[Unit]
Description=Kocaptcha captcha service
After=network.target

[Service]
ExecStart=/var/lib/pleroma/kocaptcha

[Install]
WantedBy = multi-user.target
```

Create Nginx configuration to point /kocaptcha to http://0.0.0.0:9093.
Edit /etc/nginx/sites-available/pleroma.nginx and add this section at the bottom.
```
    location /kocaptcha/ {
        proxy_pass http://0.0.0.0:9093/;
    }
```

Reload nginx
```
# systemctl reload nginx
```

Open pleroma configuration at /opt/pleroma/config/prod.secret.exs and add the following line
```elixir
config :pleroma, Pleroma.Captcha.Kocaptcha, endpoint: "https://<my-pleroma-instance>/kocaptcha"
```

Restart pleroma service
```
# systemctl restart pleroma
```

Go to path https://<my-pleroma-instance>/registration in a new private window to see if the captcha image is loading.

