webpackJsonp([13],{149:function(e,t,o){"use strict";o.d(t,"a",function(){return m});var n,a,i=o(2),c=o.n(i),s=o(1),r=o.n(s),l=o(3),u=o.n(l),d=o(4),f=o.n(d),p=o(0),g=o.n(p),h=o(6),m=(a=n=function(e){function t(){return r()(this,t),u()(this,e.apply(this,arguments))}return f()(t,e),t.prototype.render=function(){var e=this.props,t=e.disabled,o=e.visible;return c()("button",{className:"load-more",disabled:t||!o,style:{visibility:o?"visible":"hidden"},onClick:this.props.onClick},void 0,c()(h.b,{id:"status.load_more",defaultMessage:"Load more"}))},t}(g.a.PureComponent),n.defaultProps={visible:!0},a)},150:function(e,t,o){"use strict";o.d(t,"a",function(){return h});var n=o(2),a=o.n(n),i=o(1),c=o.n(i),s=o(3),r=o.n(s),l=o(4),u=o.n(l),d=o(0),f=o.n(d),p=o(10),g=o.n(p),h=function(e){function t(){var o,n,a;c()(this,t);for(var i=arguments.length,s=Array(i),l=0;l<i;l++)s[l]=arguments[l];return o=n=r()(this,e.call.apply(e,[this].concat(s))),n.handleClick=function(){n.props.onClick()},a=o,r()(n,a)}return u()(t,e),t.prototype.render=function(){var e=this.props,t=e.icon,o=e.type,n=e.active,i=e.columnHeaderId,c="";return t&&(c=a()("i",{className:"fa fa-fw fa-"+t+" column-header__icon"})),a()("h1",{className:g()("column-header",{active:n}),id:i||null},void 0,a()("button",{onClick:this.handleClick},void 0,c,o))},t}(f.a.PureComponent)},282:function(e,t,o){"use strict";function n(e){return function(t){t({type:i,account:e}),t(Object(a.d)("MUTE"))}}t.a=n;var a=(o(14),o(22),o(15),o(26)),i="MUTES_INIT_MODAL"},283:function(e,t,o){"use strict";o.d(t,"a",function(){return b});var n=o(2),a=o.n(n),i=o(1),c=o.n(i),s=o(3),r=o.n(s),l=o(4),u=o.n(l),d=o(34),f=o.n(d),p=o(0),g=o.n(p),h=o(150),m=o(91),v=o(35),b=function(e){function t(){var o,n,a;c()(this,t);for(var i=arguments.length,s=Array(i),l=0;l<i;l++)s[l]=arguments[l];return o=n=r()(this,e.call.apply(e,[this].concat(s))),n.handleHeaderClick=function(){var e=n.node.querySelector(".scrollable");e&&(n._interruptScrollAnimation=Object(m.b)(e))},n.handleScroll=f()(function(){void 0!==n._interruptScrollAnimation&&n._interruptScrollAnimation()},200),n.setRef=function(e){n.node=e},a=o,r()(n,a)}return u()(t,e),t.prototype.scrollTop=function(){var e=this.node.querySelector(".scrollable");e&&(this._interruptScrollAnimation=Object(m.b)(e))},t.prototype.render=function(){var e=this.props,t=e.heading,o=e.icon,n=e.children,i=e.active,c=e.hideHeadingOnMobile,s=t&&(!c||c&&!Object(v.b)(window.innerWidth)),r=s&&t.replace(/ /g,"-"),l=s&&a()(h.a,{icon:o,active:i,type:t,onClick:this.handleHeaderClick,columnHeaderId:r});return g.a.createElement("div",{ref:this.setRef,role:"region","aria-labelledby":r,className:"column",onScroll:this.handleScroll},l,n)},t}(g.a.PureComponent)},286:function(e,t,o){"use strict";o.d(t,"a",function(){return b});var n,a,i=o(2),c=o.n(i),s=o(1),r=o.n(s),l=o(3),u=o.n(l),d=o(4),f=o.n(d),p=o(0),g=o.n(p),h=o(6),m=o(5),v=o.n(m),b=(a=n=function(e){function t(){var o,n,a;r()(this,t);for(var i=arguments.length,c=Array(i),s=0;s<i;s++)c[s]=arguments[s];return o=n=u()(this,e.call.apply(e,[this].concat(c))),n.handleClick=function(){window.history&&1===window.history.length?n.context.router.history.push("/"):n.context.router.history.goBack()},a=o,u()(n,a)}return f()(t,e),t.prototype.render=function(){return c()("button",{onClick:this.handleClick,className:"column-back-button"},void 0,c()("i",{className:"fa fa-fw fa-chevron-left column-back-button__icon"}),c()(h.b,{id:"column_back_button.label",defaultMessage:"Back"}))},t}(g.a.PureComponent),n.contextTypes={router:v.a.object},a)},815:function(e,t,o){"use strict";Object.defineProperty(t,"__esModule",{value:!0}),o.d(t,"default",function(){return F});var n,a,i,c,s=o(2),r=o.n(s),l=o(1),u=o.n(l),d=o(3),f=o.n(d),p=o(4),g=o.n(p),h=o(0),m=(o.n(h),o(9)),v=o(5),b=o.n(v),_=o(13),M=o.n(_),w=o(296),k=o(22),y=o(151),O=o(841),I=o(283),N=o(844),j=o(149),C=o(286),R=o(12),q=o.n(R),T=function(e,t){return{accountIds:e.getIn(["user_lists","followers",t.params.accountId,"items"]),hasMore:!!e.getIn(["user_lists","followers",t.params.accountId,"next"])}},F=(n=Object(m.connect)(T))((c=i=function(e){function t(){var o,n,a;u()(this,t);for(var i=arguments.length,c=Array(i),s=0;s<i;s++)c[s]=arguments[s];return o=n=f()(this,e.call.apply(e,[this].concat(c))),n.handleScroll=function(e){var t=e.target;t.scrollTop===t.scrollHeight-t.clientHeight&&n.props.hasMore&&n.props.dispatch(Object(k.s)(n.props.params.accountId))},n.handleLoadMore=function(e){e.preventDefault(),n.props.dispatch(Object(k.s)(n.props.params.accountId))},a=o,f()(n,a)}return g()(t,e),t.prototype.componentWillMount=function(){this.props.dispatch(Object(k.u)(this.props.params.accountId)),this.props.dispatch(Object(k.w)(this.props.params.accountId))},t.prototype.componentWillReceiveProps=function(e){e.params.accountId!==this.props.params.accountId&&e.params.accountId&&(this.props.dispatch(Object(k.u)(e.params.accountId)),this.props.dispatch(Object(k.w)(e.params.accountId)))},t.prototype.render=function(){var e=this.props,t=e.accountIds,o=e.hasMore,n=null;return t?(o&&(n=r()(j.a,{onClick:this.handleLoadMore})),r()(I.a,{},void 0,r()(C.a,{}),r()(y.a,{scrollKey:"followers"},void 0,r()("div",{className:"scrollable",onScroll:this.handleScroll},void 0,r()("div",{className:"followers"},void 0,r()(N.a,{accountId:this.props.params.accountId,hideTabs:!0}),t.map(function(e){return r()(O.a,{id:e,withNote:!1},e)}),n))))):r()(I.a,{},void 0,r()(w.a,{}))},t}(q.a),i.propTypes={params:b.a.object.isRequired,dispatch:b.a.func.isRequired,accountIds:M.a.list,hasMore:b.a.bool},a=c))||a},841:function(e,t,o){"use strict";var n=o(2),a=o.n(n),i=o(0),c=(o.n(i),o(9)),s=o(6),r=o(67),l=o(842),u=o(22),d=o(26),f=o(282),p=o(11),g=Object(s.f)({unfollowConfirm:{id:"confirmations.unfollow.confirm",defaultMessage:"Unfollow"}}),h=function(){var e=Object(r.c)();return function(t,o){return{account:e(t,o.id)}}},m=function(e,t){var o=t.intl;return{onFollow:function(t){e(t.getIn(["relationship","following"])||t.getIn(["relationship","requested"])?p.j?Object(d.d)("CONFIRM",{message:a()(s.b,{id:"confirmations.unfollow.message",defaultMessage:"Are you sure you want to unfollow {name}?",values:{name:a()("strong",{},void 0,"@",t.get("acct"))}}),confirm:o.formatMessage(g.unfollowConfirm),onConfirm:function(){return e(Object(u.D)(t.get("id")))}}):Object(u.D)(t.get("id")):Object(u.z)(t.get("id")))},onBlock:function(t){e(t.getIn(["relationship","blocking"])?Object(u.C)(t.get("id")):Object(u.q)(t.get("id")))},onMute:function(t){e(t.getIn(["relationship","muting"])?Object(u.E)(t.get("id")):Object(f.a)(t))},onMuteNotifications:function(t,o){e(Object(u.A)(t.get("id"),o))}}};t.a=Object(s.g)(Object(c.connect)(h,m)(l.a))},842:function(e,t,o){"use strict";o.d(t,"a",function(){return C});var n,a,i,c=o(2),s=o.n(c),r=o(1),l=o.n(r),u=o(3),d=o.n(u),f=o(4),p=o.n(f),g=o(0),h=(o.n(g),o(13)),m=o.n(h),v=o(5),b=o.n(v),_=o(57),M=o(56),w=o(295),k=o(23),y=o(6),O=o(12),I=o.n(O),N=o(11),j=Object(y.f)({follow:{id:"account.follow",defaultMessage:"Follow"},unfollow:{id:"account.unfollow",defaultMessage:"Unfollow"},requested:{id:"account.requested",defaultMessage:"Awaiting approval"},unblock:{id:"account.unblock",defaultMessage:"Unblock @{name}"},unmute:{id:"account.unmute",defaultMessage:"Unmute @{name}"},mute_notifications:{id:"account.mute_notifications",defaultMessage:"Mute notifications from @{name}"},unmute_notifications:{id:"account.unmute_notifications",defaultMessage:"Unmute notifications from @{name}"}}),C=Object(y.g)((i=a=function(e){function t(){var o,n,a;l()(this,t);for(var i=arguments.length,c=Array(i),s=0;s<i;s++)c[s]=arguments[s];return o=n=d()(this,e.call.apply(e,[this].concat(c))),n.handleFollow=function(){n.props.onFollow(n.props.account)},n.handleBlock=function(){n.props.onBlock(n.props.account)},n.handleMute=function(){n.props.onMute(n.props.account)},n.handleMuteNotifications=function(){n.props.onMuteNotifications(n.props.account,!0)},n.handleUnmuteNotifications=function(){n.props.onMuteNotifications(n.props.account,!1)},a=o,d()(n,a)}return p()(t,e),t.prototype.render=function(){var e=this.props,t=e.account,o=e.intl,n=e.hidden;if(!t)return s()("div",{});if(n)return s()("div",{},void 0,t.get("display_name"),t.get("username"));var a=void 0;if(t.get("id")!==N.g&&null!==t.get("relationship",null)){var i=t.getIn(["relationship","following"]),c=t.getIn(["relationship","requested"]),r=t.getIn(["relationship","blocking"]),l=t.getIn(["relationship","muting"]);if(c)a=s()(k.a,{disabled:!0,icon:"hourglass",title:o.formatMessage(j.requested)});else if(r)a=s()(k.a,{active:!0,icon:"unlock-alt",title:o.formatMessage(j.unblock,{name:t.get("username")}),onClick:this.handleBlock});else if(l){var u=void 0;u=t.getIn(["relationship","muting_notifications"])?s()(k.a,{active:!0,icon:"bell",title:o.formatMessage(j.unmute_notifications,{name:t.get("username")}),onClick:this.handleUnmuteNotifications}):s()(k.a,{active:!0,icon:"bell-slash",title:o.formatMessage(j.mute_notifications,{name:t.get("username")}),onClick:this.handleMuteNotifications}),a=s()(g.Fragment,{},void 0,s()(k.a,{active:!0,icon:"volume-up",title:o.formatMessage(j.unmute,{name:t.get("username")}),onClick:this.handleMute}),u)}else t.get("moved")&&!i||(a=s()(k.a,{icon:i?"user-times":"user-plus",title:o.formatMessage(i?j.unfollow:j.follow),onClick:this.handleFollow,active:i}))}return s()("div",{className:"account"},void 0,s()("div",{className:"account__wrapper"},void 0,s()(w.a,{className:"account__display-name",href:t.get("url"),to:"/accounts/"+t.get("id")},t.get("id"),s()("div",{className:"account__avatar-wrapper"},void 0,s()(_.a,{account:t,size:36})),s()(M.a,{account:t})),s()("div",{className:"account__relationship"},void 0,a)))},t}(I.a),a.propTypes={account:m.a.map.isRequired,onFollow:b.a.func.isRequired,onBlock:b.a.func.isRequired,onMute:b.a.func.isRequired,onMuteNotifications:b.a.func.isRequired,intl:b.a.object.isRequired,hidden:b.a.bool},n=i))||n},843:function(e,t,o){"use strict";var n=o(2),a=o.n(n),i=o(0),c=(o.n(i),o(6)),s=function(){return a()("div",{className:"regeneration-indicator missing-indicator"},void 0,a()("div",{},void 0,a()("div",{className:"regeneration-indicator__label"},void 0,a()(c.b,{id:"missing_indicator.label",tagName:"strong",defaultMessage:"Not found"}),a()(c.b,{id:"missing_indicator.sublabel",defaultMessage:"This resource could not be found"}))))};t.a=s},844:function(e,t,o){"use strict";var n=o(2),a=o.n(n),i=o(0),c=(o.n(i),o(9)),s=o(67),r=o(845),l=o(22),u=o(18),d=o(282),f=o(26),p=o(6),g=o(11),h=Object(p.f)({unfollowConfirm:{id:"confirmations.unfollow.confirm",defaultMessage:"Unfollow"},blockConfirm:{id:"confirmations.block.confirm",defaultMessage:"Block"}}),m=function(){var e=Object(s.c)();return function(t,o){var n=o.accountId;return{account:e(t,n)}}},v=function(e,t){var o=t.intl;return{onFollow:function(t){e(t.getIn(["relationship","following"])||t.getIn(["relationship","requested"])?g.j?Object(f.d)("CONFIRM",{message:a()(p.b,{id:"confirmations.unfollow.message",defaultMessage:"Are you sure you want to unfollow {name}?",values:{name:a()("strong",{},void 0,"@",t.get("acct"))}}),confirm:o.formatMessage(h.unfollowConfirm),onConfirm:function(){return e(Object(l.D)(t.get("id")))}}):Object(l.D)(t.get("id")):Object(l.z)(t.get("id")))},onBlock:function(t){e(t.getIn(["relationship","blocking"])?Object(l.C)(t.get("id")):Object(f.d)("CONFIRM",{message:a()(p.b,{id:"confirmations.block.message",defaultMessage:"Are you sure you want to block {name}?",values:{name:a()("strong",{},void 0,"@",t.get("acct"))}}),confirm:o.formatMessage(h.blockConfirm),onConfirm:function(){return e(Object(l.q)(t.get("id")))}}))},onMention:function(t,o){e(Object(u.R)(t,o))},onDirect:function(t,o){e(Object(u.N)(t,o))},onReblogToggle:function(t){e(t.getIn(["relationship","showing_reblogs"])?Object(l.z)(t.get("id"),!1):Object(l.z)(t.get("id"),!0))},onMute:function(t){e(t.getIn(["relationship","muting"])?Object(l.E)(t.get("id")):Object(d.a)(t))}}};t.a=Object(p.g)(Object(c.connect)(m,v)(r.a))},845:function(e,t,o){"use strict";o.d(t,"a",function(){return N});var n,a,i=o(2),c=o.n(i),s=o(1),r=o.n(s),l=o(3),u=o.n(l),d=o(4),f=o.n(d),p=o(0),g=(o.n(p),o(13)),h=o.n(g),m=o(5),v=o.n(m),b=o(846),_=o(847),M=o(843),w=o(12),k=o.n(w),y=o(848),O=o(6),I=o(45),N=(a=n=function(e){function t(){var o,n,a;r()(this,t);for(var i=arguments.length,c=Array(i),s=0;s<i;s++)c[s]=arguments[s];return o=n=u()(this,e.call.apply(e,[this].concat(c))),n.handleFollow=function(){n.props.onFollow(n.props.account)},n.handleBlock=function(){n.props.onBlock(n.props.account)},n.handleMention=function(){n.props.onMention(n.props.account,n.context.router.history)},n.handleDirect=function(){n.props.onDirect(n.props.account,n.context.router.history)},n.handleReblogToggle=function(){n.props.onReblogToggle(n.props.account)},n.handleMute=function(){n.props.onMute(n.props.account)},a=o,u()(n,a)}return f()(t,e),t.prototype.render=function(){var e=this.props,t=e.account,o=e.hideTabs;return null===t?c()(M.a,{}):c()("div",{className:"account-timeline__header"},void 0,t.get("moved")&&c()(y.a,{from:t,to:t.get("moved")}),c()(b.a,{account:t,onFollow:this.handleFollow,onBlock:this.handleBlock}),c()(_.a,{account:t,onBlock:this.handleBlock,onMention:this.handleMention,onDirect:this.handleDirect,onReblogToggle:this.handleReblogToggle,onMute:this.handleMute}),!o&&c()("div",{className:"account__section-headline"},void 0,c()(I.c,{exact:!0,to:"/accounts/"+t.get("id")},void 0,c()(O.b,{id:"account.posts",defaultMessage:"Toots"})),c()(I.c,{exact:!0,to:"/accounts/"+t.get("id")+"/with_replies"},void 0,c()(O.b,{id:"account.posts_with_replies",defaultMessage:"Toots and replies"})),c()(I.c,{exact:!0,to:"/accounts/"+t.get("id")+"/media"},void 0,c()(O.b,{id:"account.media",defaultMessage:"Media"}))))},t}(k.a),n.propTypes={account:h.a.map,onFollow:v.a.func.isRequired,onBlock:v.a.func.isRequired,onMention:v.a.func.isRequired,onDirect:v.a.func.isRequired,onReblogToggle:v.a.func.isRequired,onMute:v.a.func.isRequired,hideTabs:v.a.bool},n.contextTypes={router:v.a.object},a)},846:function(e,t,o){"use strict";o.d(t,"a",function(){return T});var n,a,i,c,s,r=o(2),l=o.n(r),u=o(1),d=o.n(u),f=o(3),p=o.n(f),g=o(4),h=o.n(g),m=o(0),v=(o.n(m),o(13)),b=o.n(v),_=o(5),M=o.n(_),w=o(6),k=o(23),y=o(27),O=(o.n(y),o(12)),I=o.n(O),N=o(11),j=o(10),C=o.n(j),R=Object(w.f)({unfollow:{id:"account.unfollow",defaultMessage:"Unfollow"},follow:{id:"account.follow",defaultMessage:"Follow"},requested:{id:"account.requested",defaultMessage:"Awaiting approval. Click to cancel follow request"},unblock:{id:"account.unblock",defaultMessage:"Unblock @{name}"}}),q=(a=n=function(e){function t(){var o,n,a;d()(this,t);for(var i=arguments.length,c=Array(i),s=0;s<i;s++)c[s]=arguments[s];return o=n=p()(this,e.call.apply(e,[this].concat(c))),n.state={isHovered:!1},n.handleMouseOver=function(){n.state.isHovered||n.setState({isHovered:!0})},n.handleMouseOut=function(){n.state.isHovered&&n.setState({isHovered:!1})},a=o,p()(n,a)}return h()(t,e),t.prototype.render=function(){var e=this.props.account,t=this.state.isHovered;return l()("a",{href:e.get("url"),className:"account__header__avatar",role:"presentation",target:"_blank",rel:"noopener",style:{backgroundImage:"url("+(N.a||t?e.get("avatar"):e.get("avatar_static"))+")"},onMouseOver:this.handleMouseOver,onMouseOut:this.handleMouseOut,onFocus:this.handleMouseOver,onBlur:this.handleMouseOut},void 0,l()("span",{style:{display:"none"}},void 0,e.get("acct")))},t}(I.a),n.propTypes={account:b.a.map.isRequired},a),T=Object(w.g)((s=c=function(e){function t(){return d()(this,t),p()(this,e.apply(this,arguments))}return h()(t,e),t.prototype.render=function(){var e=this.props,t=e.account,o=e.intl;if(!t)return null;var n="",a="",i="",c="";N.g!==t.get("id")&&t.getIn(["relationship","followed_by"])?n=l()("span",{className:"account--follows-info"},void 0,l()(w.b,{id:"account.follows_you",defaultMessage:"Follows you"})):N.g!==t.get("id")&&t.getIn(["relationship","blocking"])&&(n=l()("span",{className:"account--follows-info"},void 0,l()(w.b,{id:"account.blocked",defaultMessage:"Blocked"}))),N.g!==t.get("id")&&t.getIn(["relationship","muting"])?a=l()("span",{className:"account--muting-info"},void 0,l()(w.b,{id:"account.muted",defaultMessage:"Muted"})):N.g!==t.get("id")&&t.getIn(["relationship","domain_blocking"])&&(a=l()("span",{className:"account--muting-info"},void 0,l()(w.b,{id:"account.domain_blocked",defaultMessage:"Domain hidden"}))),N.g!==t.get("id")&&(t.getIn(["relationship","requested"])?i=l()("div",{className:"account--action-button"},void 0,l()(k.a,{size:26,active:!0,icon:"hourglass",title:o.formatMessage(R.requested),onClick:this.props.onFollow})):t.getIn(["relationship","blocking"])?t.getIn(["relationship","blocking"])&&(i=l()("div",{className:"account--action-button"},void 0,l()(k.a,{size:26,icon:"unlock-alt",title:o.formatMessage(R.unblock,{name:t.get("username")}),onClick:this.props.onBlock}))):i=l()("div",{className:"account--action-button"},void 0,l()(k.a,{size:26,icon:t.getIn(["relationship","following"])?"user-times":"user-plus",active:t.getIn(["relationship","following"]),title:o.formatMessage(t.getIn(["relationship","following"])?R.unfollow:R.follow),onClick:this.props.onFollow}))),t.get("moved")&&!t.getIn(["relationship","following"])&&(i=""),t.get("locked")&&(c=l()("i",{className:"fa fa-lock"}));var s={__html:t.get("note_emojified")},r={__html:t.get("display_name_html")};return l()("div",{className:C()("account__header",{inactive:!!t.get("moved")}),style:{backgroundImage:"url("+t.get("header")+")"}},void 0,l()("div",{},void 0,l()(q,{account:t}),l()("span",{className:"account__header__display-name",dangerouslySetInnerHTML:r}),l()("span",{className:"account__header__username"},void 0,"@",t.get("acct")," ",c),l()("div",{className:"account__header__content",dangerouslySetInnerHTML:s}),n,a,i))},t}(I.a),c.propTypes={account:b.a.map,onFollow:M.a.func.isRequired,onBlock:M.a.func.isRequired,intl:M.a.object.isRequired},i=s))||i},847:function(e,t,o){"use strict";o.d(t,"a",function(){return _});var n,a=o(2),i=o.n(a),c=o(1),s=o.n(c),r=o(3),l=o.n(r),u=o(4),d=o.n(u),f=o(0),p=o.n(f),g=o(299),h=o(45),m=o(6),v=o(11),b=Object(m.f)({mention:{id:"account.mention",defaultMessage:"Mention @{name}"},direct:{id:"account.direct",defaultMessage:"Direct message @{name}"},edit_profile:{id:"account.edit_profile",defaultMessage:"Edit profile"},unblock:{id:"account.unblock",defaultMessage:"Unblock @{name}"},unfollow:{id:"account.unfollow",defaultMessage:"Unfollow"},block:{id:"account.block",defaultMessage:"Block @{name}"},follow:{id:"account.follow",defaultMessage:"Follow"},report:{id:"account.report",defaultMessage:"Report @{name}"},share:{id:"account.share",defaultMessage:"Share @{name}'s profile"},media:{id:"account.media",defaultMessage:"Media"},hideReblogs:{id:"account.hide_reblogs",defaultMessage:"Hide boosts from @{name}"},showReblogs:{id:"account.show_reblogs",defaultMessage:"Show boosts from @{name}"}}),_=Object(m.g)(n=function(e){function t(){var o,n,a;s()(this,t);for(var i=arguments.length,c=Array(i),r=0;r<i;r++)c[r]=arguments[r];return o=n=l()(this,e.call.apply(e,[this].concat(c))),n.handleShare=function(){navigator.share({url:n.props.account.get("url")})},a=o,l()(n,a)}return d()(t,e),t.prototype.render=function(){var e=this.props,t=e.account,o=e.intl,n=[],a="";return n.push({text:o.formatMessage(b.mention,{name:t.get("username")}),action:this.props.onMention}),n.push({text:o.formatMessage(b.direct,{name:t.get("username")}),action:this.props.onDirect}),"share"in navigator&&n.push({text:o.formatMessage(b.share,{name:t.get("username")}),action:this.handleShare}),n.push(null),t.get("id")===v.g?n.push({text:o.formatMessage(b.edit_profile),href:"/settings/profile"}):(t.getIn(["relationship","following"])&&(t.getIn(["relationship","showing_reblogs"])?n.push({text:o.formatMessage(b.hideReblogs,{name:t.get("username")}),action:this.props.onReblogToggle}):n.push({text:o.formatMessage(b.showReblogs,{name:t.get("username")}),action:this.props.onReblogToggle})),t.getIn(["relationship","blocking"])?n.push({text:o.formatMessage(b.unblock,{name:t.get("username")}),action:this.props.onBlock}):n.push({text:o.formatMessage(b.block,{name:t.get("username")}),action:this.props.onBlock}),n.push({text:o.formatMessage(b.report,{name:t.get("username")}),action:this.props.onReport})),t.get("acct")!==t.get("username")&&(a=i()("div",{className:"account__disclaimer"},void 0,i()(m.b,{id:"account.disclaimer_full",defaultMessage:"Information below may reflect the user's profile incompletely."})," ",i()("a",{target:"_blank",rel:"noopener",href:t.get("url")},void 0,i()(m.b,{id:"account.view_full_profile",defaultMessage:"View full profile"}))),n.push(null)),i()("div",{},void 0,a,i()("div",{className:"account__action-bar"},void 0,i()("div",{className:"account__action-bar-dropdown"},void 0,i()(g.a,{items:n,icon:"bars",size:24,direction:"right"})),i()("div",{className:"account__action-bar-links"},void 0,i()(h.b,{className:"account__action-bar__tab",to:"/accounts/"+t.get("id")},void 0,i()("span",{},void 0,i()(m.b,{id:"account.posts",defaultMessage:"Toots"})),i()("strong",{},void 0,i()(m.c,{value:t.get("statuses_count")}))),i()(h.b,{className:"account__action-bar__tab",to:"/accounts/"+t.get("id")+"/following"},void 0,i()("span",{},void 0,i()(m.b,{id:"account.follows",defaultMessage:"Follows"})),i()("strong",{},void 0,i()(m.c,{value:t.get("following_count")}))),i()(h.b,{className:"account__action-bar__tab",to:"/accounts/"+t.get("id")+"/followers"},void 0,i()("span",{},void 0,i()(m.b,{id:"account.followers",defaultMessage:"Followers"})),i()("strong",{},void 0,i()(m.c,{value:t.get("followers_count")}))))))},t}(p.a.PureComponent))||n},848:function(e,t,o){"use strict";o.d(t,"a",function(){return y});var n,a,i=o(2),c=o.n(i),s=o(1),r=o.n(s),l=o(3),u=o.n(l),d=o(4),f=o.n(d),p=o(0),g=(o.n(p),o(5)),h=o.n(g),m=o(13),v=o.n(m),b=o(6),_=o(12),M=o.n(_),w=o(301),k=o(56),y=(a=n=function(e){function t(){var o,n,a;r()(this,t);for(var i=arguments.length,c=Array(i),s=0;s<i;s++)c[s]=arguments[s];return o=n=u()(this,e.call.apply(e,[this].concat(c))),n.handleAccountClick=function(e){0===e.button&&(e.preventDefault(),n.context.router.history.push("/accounts/"+n.props.to.get("id"))),e.stopPropagation()},a=o,u()(n,a)}return f()(t,e),t.prototype.render=function(){var e=this.props,t=e.from,o=e.to,n={__html:t.get("display_name_html")};return c()("div",{className:"account__moved-note"},void 0,c()("div",{className:"account__moved-note__message"},void 0,c()("div",{className:"account__moved-note__icon-wrapper"},void 0,c()("i",{className:"fa fa-fw fa-suitcase account__moved-note__icon"})),c()(b.b,{id:"account.moved_to",defaultMessage:"{name} has moved to:",values:{name:c()("bdi",{},void 0,c()("strong",{dangerouslySetInnerHTML:n}))}})),c()("a",{href:o.get("url"),onClick:this.handleAccountClick,className:"detailed-status__display-name"},void 0,c()("div",{className:"detailed-status__display-avatar"},void 0,c()(w.a,{account:o,friend:t})),c()(k.a,{account:o})))},t}(M.a),n.contextTypes={router:h.a.object},n.propTypes={from:v.a.map.isRequired,to:v.a.map.isRequired},a)}});
//# sourceMappingURL=followers.js.map