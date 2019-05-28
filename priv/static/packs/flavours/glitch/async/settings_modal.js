(window.webpackJsonp=window.webpackJsonp||[]).push([[76],{693:function(e,t,a){"use strict";a.r(t);var s,n,m=a(0),i=a(3),o=a(7),l=a(1),d=a(2),c=a.n(d),g=a(24),r=a(6),b=function(s){function e(){for(var d,e=arguments.length,t=new Array(e),a=0;a<e;a++)t[a]=arguments[a];return d=s.call.apply(s,[this].concat(t))||this,Object(l.a)(Object(i.a)(d),"handleChange",function(e){var t=e.target,a=d.props,s=a.item,n=a.onChange,i=a.options,o=a.placeholder;i&&0<i.length?n(s,t.value):n(s,o?t.value:t.checked)}),d}return Object(o.a)(e,s),e.prototype.render=function(){var a=this.handleChange,e=this.props,t=e.settings,s=e.item,n=e.id,i=e.options,o=e.children,d=e.dependsOn,l=e.dependsOnNot,c=e.placeholder,g=!0;if(d)for(var r=0;r<d.length;r++)g=g&&t.getIn(d[r]);if(l)for(var b=0;b<l.length;b++)g=g&&!t.getIn(l[b]);if(i&&0<i.length){var p=t.getIn(s),u=i&&0<i.length&&i.map(function(e){var t=n+"--"+e.value;return Object(m.a)("label",{htmlFor:t},void 0,Object(m.a)("input",{type:"radio",name:n,id:t,value:e.value,onBlur:a,onChange:a,checked:p===e.value,disabled:!g}),e.message,e.hint&&Object(m.a)("span",{class:"hint"},void 0,e.hint))});return Object(m.a)("div",{class:"glitch local-settings__page__item radio_buttons"},void 0,Object(m.a)("fieldset",{},void 0,Object(m.a)("legend",{},void 0,o),u))}return c?Object(m.a)("div",{className:"glitch local-settings__page__item string"},void 0,Object(m.a)("label",{htmlFor:n},void 0,Object(m.a)("p",{},void 0,o),Object(m.a)("p",{},void 0,Object(m.a)("input",{id:n,type:"text",value:t.getIn(s),placeholder:c,onChange:a,disabled:!g})))):Object(m.a)("div",{className:"glitch local-settings__page__item boolean"},void 0,Object(m.a)("label",{htmlFor:n},void 0,Object(m.a)("input",{id:n,type:"checkbox",checked:t.getIn(s),onChange:a,disabled:!g}),o))},e}(c.a.PureComponent),p=Object(r.f)({layout_auto:{id:"layout.auto",defaultMessage:"Auto"},layout_desktop:{id:"layout.desktop",defaultMessage:"Desktop"},layout_mobile:{id:"layout.single",defaultMessage:"Mobile"},side_arm_none:{id:"settings.side_arm.none",defaultMessage:"None"},side_arm_keep:{id:"settings.side_arm_reply_mode.keep",defaultMessage:"Keep secondary toot button to set privacy"},side_arm_copy:{id:"settings.side_arm_reply_mode.copy",defaultMessage:"Copy privacy setting of the toot being replied to"},side_arm_restrict:{id:"settings.side_arm_reply_mode.restrict",defaultMessage:"Restrict privacy setting to that of the toot being replied to"},regexp:{id:"settings.content_warnings.regexp",defaultMessage:"Regular expression"}}),u=Object(r.g)(s=function(n){function e(){for(var e,t=arguments.length,a=new Array(t),s=0;s<t;s++)a[s]=arguments[s];return e=n.call.apply(n,[this].concat(a))||this,Object(l.a)(Object(i.a)(e),"pages",[function(e){var t=e.intl,a=e.onChange,s=e.settings;return Object(m.a)("div",{className:"glitch local-settings__page general"},void 0,Object(m.a)("h1",{},void 0,Object(m.a)(r.b,{id:"settings.general",defaultMessage:"General"})),Object(m.a)(b,{settings:s,item:["show_reply_count"],id:"mastodon-settings--reply-count",onChange:a},void 0,Object(m.a)(r.b,{id:"settings.show_reply_counter",defaultMessage:"Display an estimate of the reply count"})),Object(m.a)("section",{},void 0,Object(m.a)("h2",{},void 0,Object(m.a)(r.b,{id:"settings.notifications_opts",defaultMessage:"Notifications options"})),Object(m.a)(b,{settings:s,item:["notifications","tab_badge"],id:"mastodon-settings--notifications-tab_badge",onChange:a},void 0,Object(m.a)(r.b,{id:"settings.notifications.tab_badge",defaultMessage:"Unread notifications badge"}),Object(m.a)("span",{className:"hint"},void 0,Object(m.a)(r.b,{id:"settings.notifications.tab_badge.hint",defaultMessage:"Display a badge for unread notifications in the column icons when the notifications column isn't open"}))),Object(m.a)(b,{settings:s,item:["notifications","favicon_badge"],id:"mastodon-settings--notifications-favicon_badge",onChange:a},void 0,Object(m.a)(r.b,{id:"settings.notifications.favicon_badge",defaultMessage:"Unread notifications favicon badge"}),Object(m.a)("span",{className:"hint"},void 0,Object(m.a)(r.b,{id:"settings.notifications.favicon_badge.hint",defaultMessage:"Add a badge for unread notifications to the favicon"})))),Object(m.a)("section",{},void 0,Object(m.a)("h2",{},void 0,Object(m.a)(r.b,{id:"settings.layout_opts",defaultMessage:"Layout options"})),Object(m.a)(b,{settings:s,item:["layout"],id:"mastodon-settings--layout",options:[{value:"auto",message:t.formatMessage(p.layout_auto)},{value:"multiple",message:t.formatMessage(p.layout_desktop)},{value:"single",message:t.formatMessage(p.layout_mobile)}],onChange:a},void 0,Object(m.a)(r.b,{id:"settings.layout",defaultMessage:"Layout:"})),Object(m.a)(b,{settings:s,item:["stretch"],id:"mastodon-settings--stretch",onChange:a},void 0,Object(m.a)(r.b,{id:"settings.wide_view",defaultMessage:"Wide view (Desktop mode only)"}),Object(m.a)("span",{className:"hint"},void 0,Object(m.a)(r.b,{id:"settings.wide_view_hint",defaultMessage:"Stretches columns to better fill the available space."}))),Object(m.a)(b,{settings:s,item:["navbar_under"],id:"mastodon-settings--navbar_under",onChange:a},void 0,Object(m.a)(r.b,{id:"settings.navbar_under",defaultMessage:"Navbar at the bottom (Mobile only)"})),Object(m.a)(b,{settings:s,item:["swipe_to_change_columns"],id:"mastodon-settings--swipe_to_change_columns",onChange:a},void 0,Object(m.a)(r.b,{id:"settings.swipe_to_change_columns",defaultMessage:"Allow swiping to change columns (Mobile only)"}))))},function(e){var t=e.intl,a=e.onChange,s=e.settings;return Object(m.a)("div",{className:"glitch local-settings__page compose_box_opts"},void 0,Object(m.a)("h1",{},void 0,Object(m.a)(r.b,{id:"settings.compose_box_opts",defaultMessage:"Compose box"})),Object(m.a)(b,{settings:s,item:["always_show_spoilers_field"],id:"mastodon-settings--always_show_spoilers_field",onChange:a},void 0,Object(m.a)(r.b,{id:"settings.always_show_spoilers_field",defaultMessage:"Always enable the Content Warning field"})),Object(m.a)(b,{settings:s,item:["preselect_on_reply"],id:"mastodon-settings--preselect_on_reply",onChange:a},void 0,Object(m.a)(r.b,{id:"settings.preselect_on_reply",defaultMessage:"Pre-select usernames on reply"}),Object(m.a)("span",{className:"hint"},void 0,Object(m.a)(r.b,{id:"settings.preselect_on_reply_hint",defaultMessage:"When replying to a conversation with multiple participants, pre-select usernames past the first"}))),Object(m.a)(b,{settings:s,item:["confirm_missing_media_description"],id:"mastodon-settings--confirm_missing_media_description",onChange:a},void 0,Object(m.a)(r.b,{id:"settings.confirm_missing_media_description",defaultMessage:"Show confirmation dialog before sending toots lacking media descriptions"})),Object(m.a)(b,{settings:s,item:["confirm_before_clearing_draft"],id:"mastodon-settings--confirm_before_clearing_draft",onChange:a},void 0,Object(m.a)(r.b,{id:"settings.confirm_before_clearing_draft",defaultMessage:"Show confirmation dialog before overwriting the message being composed"})),Object(m.a)(b,{settings:s,item:["side_arm"],id:"mastodon-settings--side_arm",options:[{value:"none",message:t.formatMessage(p.side_arm_none)},{value:"direct",message:t.formatMessage({id:"privacy.direct.short"})},{value:"private",message:t.formatMessage({id:"privacy.private.short"})},{value:"unlisted",message:t.formatMessage({id:"privacy.unlisted.short"})},{value:"public",message:t.formatMessage({id:"privacy.public.short"})}],onChange:a},void 0,Object(m.a)(r.b,{id:"settings.side_arm",defaultMessage:"Secondary toot button:"})),Object(m.a)(b,{settings:s,item:["side_arm_reply_mode"],id:"mastodon-settings--side_arm_reply_mode",options:[{value:"keep",message:t.formatMessage(p.side_arm_keep)},{value:"copy",message:t.formatMessage(p.side_arm_copy)},{value:"restrict",message:t.formatMessage(p.side_arm_restrict)}],onChange:a},void 0,Object(m.a)(r.b,{id:"settings.side_arm_reply_mode",defaultMessage:"When replying to a toot:"})))},function(e){var t=e.intl,a=e.onChange,s=e.settings;return Object(m.a)("div",{className:"glitch local-settings__page content_warnings"},void 0,Object(m.a)("h1",{},void 0,Object(m.a)(r.b,{id:"settings.content_warnings",defaultMessage:"Content warnings"})),Object(m.a)(b,{settings:s,item:["content_warnings","auto_unfold"],id:"mastodon-settings--content_warnings-auto_unfold",onChange:a},void 0,Object(m.a)(r.b,{id:"settings.enable_content_warnings_auto_unfold",defaultMessage:"Automatically unfold content-warnings"})),Object(m.a)(b,{settings:s,item:["content_warnings","filter"],id:"mastodon-settings--content_warnings-auto_unfold",onChange:a,dependsOn:[["content_warnings","auto_unfold"]],placeholder:t.formatMessage(p.regexp)},void 0,Object(m.a)(r.b,{id:"settings.content_warnings_filter",defaultMessage:"Content warnings to not automatically unfold:"})))},function(e){var t=e.onChange,a=e.settings;return Object(m.a)("div",{className:"glitch local-settings__page collapsed"},void 0,Object(m.a)("h1",{},void 0,Object(m.a)(r.b,{id:"settings.collapsed_statuses",defaultMessage:"Collapsed toots"})),Object(m.a)(b,{settings:a,item:["collapsed","enabled"],id:"mastodon-settings--collapsed-enabled",onChange:t},void 0,Object(m.a)(r.b,{id:"settings.enable_collapsed",defaultMessage:"Enable collapsed toots"})),Object(m.a)(b,{settings:a,item:["collapsed","show_action_bar"],id:"mastodon-settings--collapsed-show-action-bar",onChange:t,dependsOn:[["collapsed","enabled"]]},void 0,Object(m.a)(r.b,{id:"settings.show_action_bar",defaultMessage:"Show action buttons in collapsed toots"})),Object(m.a)("section",{},void 0,Object(m.a)("h2",{},void 0,Object(m.a)(r.b,{id:"settings.auto_collapse",defaultMessage:"Automatic collapsing"})),Object(m.a)(b,{settings:a,item:["collapsed","auto","all"],id:"mastodon-settings--collapsed-auto-all",onChange:t,dependsOn:[["collapsed","enabled"]]},void 0,Object(m.a)(r.b,{id:"settings.auto_collapse_all",defaultMessage:"Everything"})),Object(m.a)(b,{settings:a,item:["collapsed","auto","notifications"],id:"mastodon-settings--collapsed-auto-notifications",onChange:t,dependsOn:[["collapsed","enabled"]],dependsOnNot:[["collapsed","auto","all"]]},void 0,Object(m.a)(r.b,{id:"settings.auto_collapse_notifications",defaultMessage:"Notifications"})),Object(m.a)(b,{settings:a,item:["collapsed","auto","lengthy"],id:"mastodon-settings--collapsed-auto-lengthy",onChange:t,dependsOn:[["collapsed","enabled"]],dependsOnNot:[["collapsed","auto","all"]]},void 0,Object(m.a)(r.b,{id:"settings.auto_collapse_lengthy",defaultMessage:"Lengthy toots"})),Object(m.a)(b,{settings:a,item:["collapsed","auto","reblogs"],id:"mastodon-settings--collapsed-auto-reblogs",onChange:t,dependsOn:[["collapsed","enabled"]],dependsOnNot:[["collapsed","auto","all"]]},void 0,Object(m.a)(r.b,{id:"settings.auto_collapse_reblogs",defaultMessage:"Boosts"})),Object(m.a)(b,{settings:a,item:["collapsed","auto","replies"],id:"mastodon-settings--collapsed-auto-replies",onChange:t,dependsOn:[["collapsed","enabled"]],dependsOnNot:[["collapsed","auto","all"]]},void 0,Object(m.a)(r.b,{id:"settings.auto_collapse_replies",defaultMessage:"Replies"})),Object(m.a)(b,{settings:a,item:["collapsed","auto","media"],id:"mastodon-settings--collapsed-auto-media",onChange:t,dependsOn:[["collapsed","enabled"]],dependsOnNot:[["collapsed","auto","all"]]},void 0,Object(m.a)(r.b,{id:"settings.auto_collapse_media",defaultMessage:"Toots with media"}))),Object(m.a)("section",{},void 0,Object(m.a)("h2",{},void 0,Object(m.a)(r.b,{id:"settings.image_backgrounds",defaultMessage:"Image backgrounds"})),Object(m.a)(b,{settings:a,item:["collapsed","backgrounds","user_backgrounds"],id:"mastodon-settings--collapsed-user-backgrouns",onChange:t,dependsOn:[["collapsed","enabled"]]},void 0,Object(m.a)(r.b,{id:"settings.image_backgrounds_users",defaultMessage:"Give collapsed toots an image background"})),Object(m.a)(b,{settings:a,item:["collapsed","backgrounds","preview_images"],id:"mastodon-settings--collapsed-preview-images",onChange:t,dependsOn:[["collapsed","enabled"]]},void 0,Object(m.a)(r.b,{id:"settings.image_backgrounds_media",defaultMessage:"Preview collapsed toot media"}))))},function(e){var t=e.onChange,a=e.settings;return Object(m.a)("div",{className:"glitch local-settings__page media"},void 0,Object(m.a)("h1",{},void 0,Object(m.a)(r.b,{id:"settings.media",defaultMessage:"Media"})),Object(m.a)(b,{settings:a,item:["media","letterbox"],id:"mastodon-settings--media-letterbox",onChange:t},void 0,Object(m.a)(r.b,{id:"settings.media_letterbox",defaultMessage:"Letterbox media"}),Object(m.a)("span",{className:"hint"},void 0,Object(m.a)(r.b,{id:"settings.media_letterbox_hint",defaultMessage:"Scale down and letterbox media to fill the image containers instead of stretching and cropping them"}))),Object(m.a)(b,{settings:a,item:["media","fullwidth"],id:"mastodon-settings--media-fullwidth",onChange:t},void 0,Object(m.a)(r.b,{id:"settings.media_fullwidth",defaultMessage:"Full-width media previews"})),Object(m.a)(b,{settings:a,item:["inline_preview_cards"],id:"mastodon-settings--inline-preview-cards",onChange:t},void 0,Object(m.a)(r.b,{id:"settings.inline_preview_cards",defaultMessage:"Inline preview cards for external links"})),Object(m.a)(b,{settings:a,item:["media","reveal_behind_cw"],id:"mastodon-settings--reveal-behind-cw",onChange:t},void 0,Object(m.a)(r.b,{id:"settings.media_reveal_behind_cw",defaultMessage:"Reveal sensitive media behind a CW by default"})))}]),e}return Object(o.a)(e,n),e.prototype.render=function(){var e=this.pages,t=this.props,a=t.index,s=t.intl,n=t.onChange,i=t.settings,o=e[a]||e[0];return Object(m.a)(o,{intl:s,onChange:n,settings:i})},e}(c.a.PureComponent))||s,_=a(12),f=a.n(_),v=function(s){function e(){for(var n,e=arguments.length,t=new Array(e),a=0;a<e;a++)t[a]=arguments[a];return n=s.call.apply(s,[this].concat(t))||this,Object(l.a)(Object(i.a)(n),"handleClick",function(e){var t=n.props,a=t.index,s=t.onNavigate;s&&(s(a),e.preventDefault())}),n}return Object(o.a)(e,s),e.prototype.render=function(){var e=this.handleClick,t=this.props,a=t.active,s=t.className,n=t.href,i=t.icon,o=t.textIcon,d=t.onNavigate,l=t.title,c=f()("glitch","local-settings__navigation__item",{active:a},s),g=i?Object(m.a)("i",{className:"fa fa-fw fa-"+i}):o?Object(m.a)("span",{className:"text-icon-button"},void 0,o):null;return n?Object(m.a)("a",{href:n,className:c},void 0,g," ",Object(m.a)("span",{},void 0,l)):d?Object(m.a)("a",{onClick:e,role:"button",tabIndex:"0",className:c},void 0,g," ",Object(m.a)("span",{},void 0,l)):null},e}(c.a.PureComponent),h=a(224),O=Object(r.f)({general:{id:"settings.general",defaultMessage:"General"},compose:{id:"settings.compose_box_opts",defaultMessage:"Compose box"},content_warnings:{id:"settings.content_warnings",defaultMessage:"Content Warnings"},collapsed:{id:"settings.collapsed_statuses",defaultMessage:"Collapsed toots"},media:{id:"settings.media",defaultMessage:"Media"},preferences:{id:"settings.preferences",defaultMessage:"Preferences"},close:{id:"settings.close",defaultMessage:"Close"}}),j=Object(r.g)(n=function(e){function t(){return e.apply(this,arguments)||this}return Object(o.a)(t,e),t.prototype.render=function(){var e=this.props,t=e.index,a=e.intl,s=e.onClose,n=e.onNavigate;return Object(m.a)("nav",{className:"glitch local-settings__navigation"},void 0,Object(m.a)(v,{active:0===t,index:0,onNavigate:n,icon:"cogs",title:a.formatMessage(O.general)}),Object(m.a)(v,{active:1===t,index:1,onNavigate:n,icon:"pencil",title:a.formatMessage(O.compose)}),Object(m.a)(v,{active:2===t,index:2,onNavigate:n,textIcon:"CW",title:a.formatMessage(O.content_warnings)}),Object(m.a)(v,{active:3===t,index:3,onNavigate:n,icon:"angle-double-up",title:a.formatMessage(O.collapsed)}),Object(m.a)(v,{active:4===t,index:4,onNavigate:n,icon:"image",title:a.formatMessage(O.media)}),Object(m.a)(v,{active:5===t,href:h.b,index:5,icon:"sliders",title:a.formatMessage(O.preferences)}),Object(m.a)(v,{active:6===t,className:"close",index:6,onNavigate:s,icon:"times",title:a.formatMessage(O.close)}))},t}(c.a.PureComponent))||n,M=a(50),y=a(363),w=function(n){function e(){for(var t,e=arguments.length,a=new Array(e),s=0;s<e;s++)a[s]=arguments[s];return t=n.call.apply(n,[this].concat(a))||this,Object(l.a)(Object(i.a)(t),"state",{currentIndex:0}),Object(l.a)(Object(i.a)(t),"navigateTo",function(e){return t.setState({currentIndex:+e})}),t}return Object(o.a)(e,n),e.prototype.render=function(){var e=this.navigateTo,t=this.props,a=t.onChange,s=t.onClose,n=t.settings,i=this.state.currentIndex;return Object(m.a)("div",{className:"glitch modal-root__modal local-settings"},void 0,Object(m.a)(j,{index:i,onClose:s,onNavigate:e}),Object(m.a)(u,{index:i,onChange:a,settings:n}))},e}(c.a.PureComponent);t.default=Object(g.connect)(function(e){return{settings:e.get("local_settings")}},function(a){return{onChange:function(e,t){a(Object(y.b)(e,t))},onClose:function(){a(Object(M.c)())}}})(w)}}]);
//# sourceMappingURL=settings_modal.js.map