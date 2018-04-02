my @fs=qw(
	installation/pleroma.vcl
	lib/jason_types.ex
	lib/pleroma/web/twitter_api/views/activity_view.ex
	priv/repo/migrations/20180325172351_add_follower_address_index_to_users.exs
	priv/repo/migrations/20180327174350_drop_local_index_on_activities.exs
	priv/repo/migrations/20180327175831_actually_drop_local_index.exs
	priv/static/favicon.png
	priv/static/static/aurora_borealis.jpg
	priv/static/static/bg2.jpg
	priv/static/static/js/app.80f69aea942d34320273.js
	priv/static/static/js/app.80f69aea942d34320273.js.map
	priv/static/static/js/manifest.845a07de7f56f746796a.js
	priv/static/static/js/manifest.845a07de7f56f746796a.js.map
	test/fixtures/httpoison_mock/framasoft@framatube.org.json
	test/fixtures/httpoison_mock/winterdienst_webfinger.json
	test/fixtures/mastodon-post-activity-hashtag.json
	test/web/twitter_api/views/activity_view_test.exs
  );

  map { unlink $_} @fs;
