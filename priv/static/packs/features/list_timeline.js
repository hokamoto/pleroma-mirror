webpackJsonp([11],{282:function(e,t,n){"use strict";function i(e){return function(t){t({type:r,account:e}),t(Object(o.d)("MUTE"))}}t.a=i;var o=(n(13),n(22),n(15),n(26)),r="MUTES_INIT_MODAL"},284:function(e,t,n){"use strict";n.d(t,"a",function(){return b});var i,o,r=n(2),s=n.n(r),a=n(1),c=n.n(a),l=n(3),d=n.n(l),u=n(4),h=n.n(u),p=n(0),f=n.n(p),g=n(6),b=(o=i=function(e){function t(){return c()(this,t),d()(this,e.apply(this,arguments))}return h()(t,e),t.prototype.render=function(){var e=this.props,t=e.disabled,n=e.visible;return s()("button",{className:"load-more",disabled:t||!n,style:{visibility:n?"visible":"hidden"},onClick:this.props.onClick},void 0,s()(g.b,{id:"status.load_more",defaultMessage:"Load more"}))},t}(f.a.PureComponent),i.defaultProps={visible:!0},o)},285:function(e,t,n){"use strict";function i(e,t){return function(n){n({type:r,account:e,status:t}),n(Object(o.d)("REPORT"))}}t.a=i;var o=(n(13),n(26)),r="REPORT_INIT"},286:function(e,t,n){"use strict";var i=n(2),o=n.n(i),r=n(0),s=(n.n(r),n(9)),a=n(151),c=n(67),l=n(18),d=n(68),u=n(22),h=n(92),p=n(282),f=n(285),g=n(26),b=n(6),v=n(12),m=(n(36),Object(b.f)({deleteConfirm:{id:"confirmations.delete.confirm",defaultMessage:"Delete"},deleteMessage:{id:"confirmations.delete.message",defaultMessage:"Are you sure you want to delete this status?"},blockConfirm:{id:"confirmations.block.confirm",defaultMessage:"Block"}})),y=function(){var e=Object(c.e)();return function(t,n){return{status:e(t,n.id)}}},O=function(e,t){var n=t.intl;return{onReply:function(t,n){e(Object(l.T)(t,n))},onModalReblog:function(t){e(Object(d.l)(t))},onReblog:function(t,n){t.get("reblogged")?e(Object(d.n)(t)):n.shiftKey||!v.b?this.onModalReblog(t):e(Object(g.d)("BOOST",{status:t,onReblog:this.onModalReblog}))},onFavourite:function(t){e(t.get("favourited")?Object(d.m)(t):Object(d.i)(t))},onDelete:function(t){e(v.e?Object(g.d)("CONFIRM",{message:n.formatMessage(m.deleteMessage),confirm:n.formatMessage(m.deleteConfirm),onConfirm:function(){return e(Object(h.f)(t.get("id")))}}):Object(h.f)(t.get("id")))},onDirect:function(t,n){e(Object(l.N)(t,n))},onMention:function(t,n){e(Object(l.R)(t,n))},onOpenMedia:function(t,n){e(Object(g.d)("MEDIA",{media:t,index:n}))},onOpenVideo:function(t,n){e(Object(g.d)("VIDEO",{media:t,time:n}))},onBlock:function(t){e(Object(g.d)("CONFIRM",{message:o()(b.b,{id:"confirmations.block.message",defaultMessage:"Are you sure you want to block {name}?",values:{name:o()("strong",{},void 0,"@",t.get("acct"))}}),confirm:n.formatMessage(m.blockConfirm),onConfirm:function(){return e(Object(u.q)(t.get("id")))}}))},onReport:function(t){e(Object(f.a)(t.get("account"),t))},onMute:function(t){e(Object(p.a)(t))},onMuteConversation:function(t){e(t.get("muted")?Object(h.k)(t.get("id")):Object(h.i)(t.get("id")))},onToggleHidden:function(t){e(t.get("hidden")?Object(h.j)(t.get("id")):Object(h.h)(t.get("id")))}}};t.a=Object(b.g)(Object(s.connect)(y,O)(a.a))},288:function(e,t,n){"use strict";n.d(t,"a",function(){return L});var i,o,r=n(2),s=n.n(r),a=n(1),c=n.n(a),l=n(3),d=n.n(l),u=n(4),h=n.n(u),p=n(94),f=n.n(p),g=n(0),b=n.n(g),v=n(150),m=n(5),y=n.n(m),O=n(289),M=n(284),I=n(294),j=n(8),C=(n.n(j),n(10)),k=n.n(C),_=n(152),L=(o=i=function(e){function t(){var n,i,o;c()(this,t);for(var r=arguments.length,s=Array(r),a=0;a<r;a++)s[a]=arguments[a];return n=i=d()(this,e.call.apply(e,[this].concat(s))),i.state={fullscreen:null},i.intersectionObserverWrapper=new I.a,i.handleScroll=f()(function(){if(i.node){var e=i.node,t=e.scrollTop;400>e.scrollHeight-t-e.clientHeight&&i.props.onLoadMore&&!i.props.isLoading&&i.props.onLoadMore(),t<100&&i.props.onScrollToTop?i.props.onScrollToTop():i.props.onScroll&&i.props.onScroll()}},150,{trailing:!0}),i.onFullScreenChange=function(){i.setState({fullscreen:Object(_.d)()})},i.setRef=function(e){i.node=e},i.handleLoadMore=function(e){e.preventDefault(),i.props.onLoadMore()},o=n,d()(i,o)}return h()(t,e),t.prototype.componentDidMount=function(){this.attachScrollListener(),this.attachIntersectionObserver(),Object(_.a)(this.onFullScreenChange),this.handleScroll()},t.prototype.getSnapshotBeforeUpdate=function(e){return b.a.Children.count(e.children)>0&&b.a.Children.count(e.children)<b.a.Children.count(this.props.children)&&this.getFirstChildKey(e)!==this.getFirstChildKey(this.props)&&this.node.scrollTop>0?this.node.scrollHeight-this.node.scrollTop:null},t.prototype.componentDidUpdate=function(e,t,n){if(null!==n){var i=this.node.scrollHeight-n;this.node.scrollTop!==i&&(this.node.scrollTop=i)}},t.prototype.componentWillUnmount=function(){this.detachScrollListener(),this.detachIntersectionObserver(),Object(_.b)(this.onFullScreenChange)},t.prototype.attachIntersectionObserver=function(){this.intersectionObserverWrapper.connect({root:this.node,rootMargin:"300% 0px"})},t.prototype.detachIntersectionObserver=function(){this.intersectionObserverWrapper.disconnect()},t.prototype.attachScrollListener=function(){this.node.addEventListener("scroll",this.handleScroll)},t.prototype.detachScrollListener=function(){this.node.removeEventListener("scroll",this.handleScroll)},t.prototype.getFirstChildKey=function(e){var t=e.children,n=t;return t instanceof j.List?n=t.get(0):Array.isArray(t)&&(n=t[0]),n&&n.key},t.prototype.render=function(){var e=this,t=this.props,n=t.children,i=t.scrollKey,o=t.trackScroll,r=t.shouldUpdateScroll,a=t.isLoading,c=t.hasMore,l=t.prepend,d=t.emptyMessage,u=t.onLoadMore,h=this.state.fullscreen,p=b.a.Children.count(n),f=c&&p>0&&u?s()(M.a,{visible:!a,onClick:this.handleLoadMore}):null,g=null;return g=a||p>0||!d?b.a.createElement("div",{className:k()("scrollable",{fullscreen:h}),ref:this.setRef},s()("div",{role:"feed",className:"item-list"},void 0,l,b.a.Children.map(this.props.children,function(t,n){return s()(O.a,{id:t.key,index:n,listLength:p,intersectionObserverWrapper:e.intersectionObserverWrapper,saveHeightKey:o?e.context.router.route.location.key+":"+i:null},t.key,t)}),f)):b.a.createElement("div",{className:"empty-column-indicator",ref:this.setRef},d),o?s()(v.a,{scrollKey:i,shouldUpdateScroll:r},void 0,g):g},t}(g.PureComponent),i.contextTypes={router:y.a.object},i.defaultProps={trackScroll:!0},o)},289:function(e,t,n){"use strict";var i=n(9),o=n(290),r=n(95),s=function(e,t){return{cachedHeight:e.getIn(["height_cache",t.saveHeightKey,t.id])}},a=function(e){return{onHeightChange:function(t,n,i){e(Object(r.d)(t,n,i))}}};t.a=Object(i.connect)(s,a)(o.a)},290:function(e,t,n){"use strict";n.d(t,"a",function(){return b});var i=n(1),o=n.n(i),r=n(3),s=n.n(r),a=n(4),c=n.n(a),l=n(0),d=n.n(l),u=n(291),h=n(293),p=n(8),f=(n.n(p),["id","index","listLength"]),g=["id","index","listLength","cachedHeight"],b=function(e){function t(){var n,i,r;o()(this,t);for(var a=arguments.length,c=Array(a),l=0;l<a;l++)c[l]=arguments[l];return n=i=s()(this,e.call.apply(e,[this].concat(c))),i.state={isHidden:!1},i.handleIntersection=function(e){i.entry=e,Object(u.a)(i.calculateHeight),i.setState(i.updateStateAfterIntersection)},i.updateStateAfterIntersection=function(e){return e.isIntersecting&&!i.entry.isIntersecting&&Object(u.a)(i.hideIfNotIntersecting),{isIntersecting:i.entry.isIntersecting,isHidden:!1}},i.calculateHeight=function(){var e=i.props,t=e.onHeightChange,n=e.saveHeightKey,o=e.id;i.height=Object(h.a)(i.entry).height,t&&n&&t(n,o,i.height)},i.hideIfNotIntersecting=function(){i.componentMounted&&i.setState(function(e){return{isHidden:!e.isIntersecting}})},i.handleRef=function(e){i.node=e},r=n,s()(i,r)}return c()(t,e),t.prototype.shouldComponentUpdate=function(e,t){var n=this,i=!this.state.isIntersecting&&(this.state.isHidden||this.props.cachedHeight);return!!i!=!(t.isIntersecting||!t.isHidden&&!e.cachedHeight)||!(i?g:f).every(function(t){return Object(p.is)(e[t],n.props[t])})},t.prototype.componentDidMount=function(){var e=this.props,t=e.intersectionObserverWrapper,n=e.id;t.observe(n,this.node,this.handleIntersection),this.componentMounted=!0},t.prototype.componentWillUnmount=function(){var e=this.props,t=e.intersectionObserverWrapper,n=e.id;t.unobserve(n,this.node),this.componentMounted=!1},t.prototype.render=function(){var e=this.props,t=e.children,n=e.id,i=e.index,o=e.listLength,r=e.cachedHeight,s=this.state,a=s.isIntersecting,c=s.isHidden;return a||!c&&!r?d.a.createElement("article",{ref:this.handleRef,"aria-posinset":i,"aria-setsize":o,"data-id":n,tabIndex:"0"},t&&d.a.cloneElement(t,{hidden:!1})):d.a.createElement("article",{ref:this.handleRef,"aria-posinset":i,"aria-setsize":o,style:{height:(this.height||r)+"px",opacity:0,overflow:"hidden"},"data-id":n,tabIndex:"0"},t&&d.a.cloneElement(t,{hidden:!0}))},t}(d.a.Component)},291:function(e,t,n){"use strict";function i(e){for(;a.length&&e.timeRemaining()>0;)a.shift()();a.length?requestIdleCallback(i):c=!1}function o(e){a.push(e),c||(c=!0,requestIdleCallback(i))}var r=n(292),s=n.n(r),a=new s.a,c=!1;t.a=o},292:function(e,t,n){"use strict";function i(){this.length=0}i.prototype.push=function(e){var t={item:e};this.last?this.last=this.last.next=t:this.last=this.first=t,this.length++},i.prototype.shift=function(){var e=this.first;if(e)return this.first=e.next,--this.length||(this.last=void 0),e.item},i.prototype.slice=function(e,t){e=void 0===e?0:e,t=void 0===t?1/0:t;for(var n=[],i=0,o=this.first;o&&!(--t<0);o=o.next)++i>e&&n.push(o.item);return n},e.exports=i},293:function(e,t,n){"use strict";function i(e){if("boolean"!=typeof o){var t=e.target.getBoundingClientRect(),n=e.boundingClientRect;o=t.height!==n.height||t.top!==n.top||t.width!==n.width||t.bottom!==n.bottom||t.left!==n.left||t.right!==n.right}return o?e.target.getBoundingClientRect():e.boundingClientRect}var o=void 0;t.a=i},294:function(e,t,n){"use strict";var i=n(1),o=n.n(i),r=function(){function e(){o()(this,e),this.callbacks={},this.observerBacklog=[],this.observer=null}return e.prototype.connect=function(e){var t=this,n=function(e){e.forEach(function(e){var n=e.target.getAttribute("data-id");t.callbacks[n]&&t.callbacks[n](e)})};this.observer=new IntersectionObserver(n,e),this.observerBacklog.forEach(function(e){var n=e[0],i=e[1],o=e[2];t.observe(n,i,o)}),this.observerBacklog=null},e.prototype.observe=function(e,t,n){this.observer?(this.callbacks[e]=n,this.observer.observe(t)):this.observerBacklog.push([e,t,n])},e.prototype.unobserve=function(e,t){this.observer&&(delete this.callbacks[e],this.observer.unobserve(t))},e.prototype.disconnect=function(){this.observer&&(this.callbacks={},this.observer.disconnect(),this.observer=null)},e}();t.a=r},295:function(e,t,n){"use strict";n.d(t,"a",function(){return b});var i,o=n(2),r=n.n(o),s=n(1),a=n.n(s),c=n(3),l=n.n(c),d=n(4),u=n.n(d),h=n(0),p=n.n(h),f=n(6),g=Object(f.f)({load_more:{id:"status.load_more",defaultMessage:"Load more"}}),b=Object(f.g)(i=function(e){function t(){var n,i,o;a()(this,t);for(var r=arguments.length,s=Array(r),c=0;c<r;c++)s[c]=arguments[c];return n=i=l()(this,e.call.apply(e,[this].concat(s))),i.handleClick=function(){i.props.onClick(i.props.maxId)},o=n,l()(i,o)}return u()(t,e),t.prototype.render=function(){var e=this.props,t=e.disabled,n=e.intl;return r()("button",{className:"load-more load-gap",disabled:t,onClick:this.handleClick,"aria-label":n.formatMessage(g.load_more)},void 0,r()("i",{className:"fa fa-ellipsis-h"}))},t}(p.a.PureComponent))||i},296:function(e,t,n){"use strict";n.d(t,"a",function(){return T});var i,o,r=n(29),s=n.n(r),a=n(2),c=n.n(a),l=n(30),d=n.n(l),u=n(1),h=n.n(u),p=n(3),f=n.n(p),g=n(4),b=n.n(g),v=n(34),m=n.n(v),y=n(0),O=n.n(y),M=n(14),I=n.n(M),j=n(5),C=n.n(j),k=n(286),_=n(11),L=n.n(_),S=n(295),R=n(288),x=n(6),T=(o=i=function(e){function t(){var n,i,o;h()(this,t);for(var r=arguments.length,s=Array(r),a=0;a<r;a++)s[a]=arguments[a];return n=i=f()(this,e.call.apply(e,[this].concat(s))),i.handleMoveUp=function(e){var t=i.props.statusIds.indexOf(e)-1;i._selectChild(t)},i.handleMoveDown=function(e){var t=i.props.statusIds.indexOf(e)+1;i._selectChild(t)},i.handleLoadOlder=m()(function(){i.props.onLoadMore(i.props.statusIds.last())},300,{leading:!0}),i.setRef=function(e){i.node=e},o=n,f()(i,o)}return b()(t,e),t.prototype._selectChild=function(e){var t=this.node.node.querySelector("article:nth-of-type("+(e+1)+") .focusable");t&&t.focus()},t.prototype.render=function(){var e=this,t=this.props,n=t.statusIds,i=t.onLoadMore,o=d()(t,["statusIds","onLoadMore"]),r=o.isLoading;if(o.isPartial)return c()("div",{className:"regeneration-indicator"},void 0,c()("div",{},void 0,c()("div",{className:"regeneration-indicator__label"},void 0,c()(x.b,{id:"regeneration_indicator.label",tagName:"strong",defaultMessage:"Loading…"}),c()(x.b,{id:"regeneration_indicator.sublabel",defaultMessage:"Your home feed is being prepared!"}))));var a=r||n.size>0?n.map(function(t,o){return null===t?c()(S.a,{disabled:r,maxId:o>0?n.get(o-1):null,onClick:i},"gap:"+n.get(o+1)):c()(k.a,{id:t,onMoveUp:e.handleMoveUp,onMoveDown:e.handleMoveDown},t)}):null;return O.a.createElement(R.a,s()({},o,{onLoadMore:i&&this.handleLoadOlder,ref:this.setRef}),a)},t}(L.a),i.propTypes={scrollKey:C.a.string.isRequired,statusIds:I.a.list.isRequired,onLoadMore:C.a.func,onScrollToTop:C.a.func,onScroll:C.a.func,trackScroll:C.a.bool,shouldUpdateScroll:C.a.func,isLoading:C.a.bool,isPartial:C.a.bool,hasMore:C.a.bool,prepend:C.a.node,emptyMessage:C.a.node},i.defaultProps={trackScroll:!0},o)},812:function(e,t,n){"use strict";Object.defineProperty(t,"__esModule",{value:!0}),n.d(t,"default",function(){return H});var i,o,r,s,a=n(2),c=n.n(a),l=n(1),d=n.n(l),u=n(3),h=n.n(u),p=n(4),f=n.n(p),g=n(0),b=n.n(g),v=n(9),m=n(5),y=n.n(m),O=n(93),M=n(70),I=n(69),j=n(299),C=n(6),k=n(71),_=n(19),L=n(302),S=n(26),R=n(846),x=n(298),T=Object(C.f)({deleteMessage:{id:"confirmations.delete_list.message",defaultMessage:"Are you sure you want to permanently delete this list?"},deleteConfirm:{id:"confirmations.delete_list.confirm",defaultMessage:"Delete"}}),N=function(e,t){return{list:e.getIn(["lists",t.params.id]),hasUnread:e.getIn(["timelines","list:"+t.params.id,"unread"])>0}},H=(i=Object(v.connect)(N))(o=Object(C.g)((s=r=function(e){function t(){var n,i,o;d()(this,t);for(var r=arguments.length,s=Array(r),a=0;a<r;a++)s[a]=arguments[a];return n=i=h()(this,e.call.apply(e,[this].concat(s))),i.handlePin=function(){var e=i.props,t=e.columnId,n=e.dispatch;t?n(Object(j.f)(t)):(n(Object(j.d)("LIST",{id:i.props.params.id})),i.context.router.history.push("/"))},i.handleMove=function(e){var t=i.props,n=t.columnId;(0,t.dispatch)(Object(j.e)(n,e))},i.handleHeaderClick=function(){i.column.scrollTop()},i.setRef=function(e){i.column=e},i.handleLoadMore=function(e){var t=i.props.params.id;i.props.dispatch(Object(_.p)(t,{maxId:e}))},i.handleEditClick=function(){i.props.dispatch(Object(S.d)("LIST_EDITOR",{listId:i.props.params.id}))},i.handleDeleteClick=function(){var e=i.props,t=e.dispatch,n=e.columnId,o=e.intl,r=i.props.params.id;t(Object(S.d)("CONFIRM",{message:o.formatMessage(T.deleteMessage),confirm:o.formatMessage(T.deleteConfirm),onConfirm:function(){t(Object(L.u)(r)),n?t(Object(j.f)(n)):i.context.router.history.push("/lists")}}))},o=n,h()(i,o)}return f()(t,e),t.prototype.componentDidMount=function(){var e=this.props.dispatch,t=this.props.params.id;e(Object(L.v)(t)),e(Object(_.p)(t)),this.disconnect=e(Object(k.c)(t))},t.prototype.componentWillUnmount=function(){this.disconnect&&(this.disconnect(),this.disconnect=null)},t.prototype.render=function(){var e=this.props,t=e.hasUnread,n=e.columnId,i=e.multiColumn,o=e.list,r=this.props.params.id,s=!!n,a=o?o.get("title"):r;return void 0===o?c()(M.a,{},void 0,c()("div",{className:"scrollable"},void 0,c()(x.a,{}))):!1===o?c()(M.a,{},void 0,c()("div",{className:"scrollable"},void 0,c()(R.a,{}))):b.a.createElement(M.a,{ref:this.setRef},c()(I.a,{icon:"bars",active:t,title:a,onPin:this.handlePin,onMove:this.handleMove,onClick:this.handleHeaderClick,pinned:s,multiColumn:i},void 0,c()("div",{className:"column-header__links"},void 0,c()("button",{className:"text-btn column-header__setting-btn",tabIndex:"0",onClick:this.handleEditClick},void 0,c()("i",{className:"fa fa-pencil"})," ",c()(C.b,{id:"lists.edit",defaultMessage:"Edit list"})),c()("button",{className:"text-btn column-header__setting-btn",tabIndex:"0",onClick:this.handleDeleteClick},void 0,c()("i",{className:"fa fa-trash"})," ",c()(C.b,{id:"lists.delete",defaultMessage:"Delete list"}))),c()("hr",{})),c()(O.a,{trackScroll:!s,scrollKey:"list_timeline-"+n,timelineId:"list:"+r,onLoadMore:this.handleLoadMore,emptyMessage:c()(C.b,{id:"empty_column.list",defaultMessage:"There is nothing in this list yet. When members of this list post new statuses, they will appear here."})}))},t}(b.a.PureComponent),r.contextTypes={router:y.a.object},o=s))||o)||o},846:function(e,t,n){"use strict";var i=n(2),o=n.n(i),r=n(0),s=(n.n(r),n(6)),a=function(){return o()("div",{className:"regeneration-indicator missing-indicator"},void 0,o()("div",{},void 0,o()("div",{className:"regeneration-indicator__label"},void 0,o()(s.b,{id:"missing_indicator.label",tagName:"strong",defaultMessage:"Not found"}),o()(s.b,{id:"missing_indicator.sublabel",defaultMessage:"This resource could not be found"}))))};t.a=a},93:function(e,t,n){"use strict";var i=n(34),o=n.n(i),r=n(9),s=n(296),a=n(19),c=n(8),l=(n.n(c),n(96)),d=(n.n(l),n(12)),u=function(){return Object(l.createSelector)([function(e,t){var n=t.type;return e.getIn(["settings",n],Object(c.Map)())},function(e,t){var n=t.type;return e.getIn(["timelines",n,"items"],Object(c.List)())},function(e){return e.get("statuses")}],function(e,t,n){var i=e.getIn(["regex","body"],"").trim(),o=null;try{o=i&&new RegExp(i,"i")}catch(e){}return t.filter(function(t){var i=n.get(t),r=!0;if(!1===e.getIn(["shows","reblog"])&&(r=r&&null===i.get("reblog")),!1===e.getIn(["shows","reply"])&&(r=r&&(null===i.get("in_reply_to_id")||i.get("in_reply_to_account_id")===d.g)),r&&o&&i.get("account")!==d.g){var s=i.get("reblog")?n.getIn([i.get("reblog"),"search_index"]):i.get("search_index");r=!o.test(s)}return r})})},h=function(){var e=u();return function(t,n){var i=n.timelineId;return{statusIds:e(t,{type:i}),isLoading:t.getIn(["timelines",i,"isLoading"],!0),isPartial:t.getIn(["timelines",i,"isPartial"],!1),hasMore:t.getIn(["timelines",i,"hasMore"])}}},p=function(e,t){var n=t.timelineId;return{onScrollToTop:o()(function(){e(Object(a.r)(n,!0))},100),onScroll:o()(function(){e(Object(a.r)(n,!1))},100)}};t.a=Object(r.connect)(h,p)(s.a)}});
//# sourceMappingURL=list_timeline.js.map