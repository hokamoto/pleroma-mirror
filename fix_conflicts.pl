my @fs=qw(
config/config.exs
lib/pleroma/application.ex
lib/pleroma/user.ex
lib/pleroma/web/activity_pub/activity_pub_controller.ex
lib/pleroma/web/activity_pub/views/user_view.ex
lib/pleroma/web/endpoint.ex
lib/pleroma/web/mastodon_api/mastodon_api_controller.ex
);
my @fs2=qw(
priv/static/packs/features/compose-4617f6e912b5bfa71c43.js
priv/static/packs/features/compose-4617f6e912b5bfa71c43.js.gz
priv/static/packs/features/compose-4617f6e912b5bfa71c43.js.map
priv/static/packs/pl-dark-masto-fe.css
);

for my $f (@fs2) {
  unlink $f;

}
