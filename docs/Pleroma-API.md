# Authentication

Requests that require it can be authenticated with [an OAuth token](https://tools.ietf.org/html/rfc6749), the `_pleroma_key` cookie, or [HTTP Basic Authentication](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization).

# Request parameters

Request parameters can be passed via [query strings](https://en.wikipedia.org/wiki/Query_string) or as [form data](https://www.w3.org/TR/html401/interact/forms.html). Files must be uploaded as `multipart/form-data`.

# Endpoints

## `/api/pleroma/emoji`
### Lists the custom emoji on that server.
* Method: `GET`
* Authentication: not required
* Params: none
* Response: JSON
* Example response: `{"kalsarikannit_f":"/finmoji/128px/kalsarikannit_f-128.png","perkele":"/finmoji/128px/perkele-128.png","blobdab":"/emoji/blobdab.png","happiness":"/finmoji/128px/happiness-128.png"}`

## `/api/pleroma/follow_import`
### Imports your follows, for example from a Mastodon CSV file.
* Method: `POST`
* Authentication: required
* Params:
    * `list`: STRING or FILE containing a whitespace-separated list of accounts to follow
* Response: HTTP 200 on success, 500 on error
* Note: Users that can't be followed are silently skipped.

## `/api/pleroma/captcha`
### Get a new captcha
* Method: `GET`
* Authentication: not required
* Params: none
* Response: Provider specific JSON, the only guaranteed parameter is `type` 
* Example response: `{"type": "kocaptcha", "token": "whatever", "url": "https://captcha.kotobank.ch/endpoint"}`

## `/api/pleroma/delete_account`
### Delete an account
* Method `POST`
* Authentication: required
* Params: 
    * `password`: user's password
* Response: JSON. Returns `{"status": "success"}` if the deletion was successful, `{"error": "[error message]"}` otherwise
* Example response: `{"error": "Invalid password."}`

## `/api/account/register`
### Register a new user
* Method `POST`
* Authentication: not required
* Params:
    * `nickname`
    * `fullname`
    * `bio`
    * `email`
    * `password`
    * `confirm`
    * `captcha_solution`: optional, contains provider-specific captcha solution,
    * `captcha_token`: optional, contains provider-specific captcha token
* Response: JSON. Returns a user object on success, otherwise returns `{"error": "error_msg"}`
* Example response:
```
{
	"background_image": null,
	"cover_photo": "https://pleroma.soykaf.com/images/banner.png",
	"created_at": "Tue Dec 18 16:55:56 +0000 2018",
	"default_scope": "public",
	"description": "blushy-crushy fediverse idol + pleroma dev\nlet's be friends \nぷれろまの生徒会長。謎の外人。日本語OK. \n公主病.",
	"description_html": "blushy-crushy fediverse idol + pleroma dev.<br />let's be friends <br />ぷれろまの生徒会長。謎の外人。日本語OK. <br />公主病.",
	"favourites_count": 0,
	"fields": [],
	"followers_count": 0,
	"following": false,
	"follows_you": false,
	"friends_count": 0,
	"id": 6,
	"is_local": true,
	"locked": false,
	"name": "lain",
	"name_html": "lain",
	"no_rich_text": false,
	"pleroma": {
		"tags": []
	},
	"profile_image_url": "https://pleroma.soykaf.com/images/avi.png",
	"profile_image_url_https": "https://pleroma.soykaf.com/images/avi.png",
	"profile_image_url_original": "https://pleroma.soykaf.com/images/avi.png",
	"profile_image_url_profile_size": "https://pleroma.soykaf.com/images/avi.png",
	"rights": {
		"delete_others_notice": false
	},
	"screen_name": "lain",
	"statuses_count": 0,
	"statusnet_blocking": false,
	"statusnet_profile_url": "https://pleroma.soykaf.com/users/lain"
}
```

## `/api/pleroma/admin/`…
See [Admin-API](Admin-API.md)
