(window.webpackJsonp=window.webpackJsonp||[]).push([[22],{707:function(e,t,a){"use strict";a.r(t);var o,c,n,i,r,s,u=a(0),l=a(3),d=a(7),j=a(1),p=a(56),b=a.n(p),f=(a(2),a(24)),h=a(6),O=a(25),v=a(5),_=a.n(v),m=a(27),g=a.n(m),w=a(272),M=a(625),q=a(632),y=a(199),z=a(378),R=a(193),N=a(194),I=a(67),k=Object(h.f)({authorize:{id:"follow_request.authorize",defaultMessage:"Authorize"},reject:{id:"follow_request.reject",defaultMessage:"Reject"}}),A=Object(h.g)((n=c=function(e){function t(){return e.apply(this,arguments)||this}return Object(d.a)(t,e),t.prototype.render=function(){var e=this.props,t=e.intl,a=e.account,o=e.onAuthorize,c=e.onReject,n={__html:a.get("note_emojified")};return Object(u.a)("div",{className:"account-authorize__wrapper"},void 0,Object(u.a)("div",{className:"account-authorize"},void 0,Object(u.a)(z.a,{href:a.get("url"),to:"/accounts/"+a.get("id"),className:"detailed-status__display-name"},void 0,Object(u.a)("div",{className:"account-authorize__avatar"},void 0,Object(u.a)(R.a,{account:a,size:48})),Object(u.a)(N.a,{account:a})),Object(u.a)("div",{className:"account__header__content",dangerouslySetInnerHTML:n})),Object(u.a)("div",{className:"account--panel"},void 0,Object(u.a)("div",{className:"account--panel__button"},void 0,Object(u.a)(I.a,{title:t.formatMessage(k.authorize),icon:"check",onClick:o})),Object(u.a)("div",{className:"account--panel__button"},void 0,Object(u.a)(I.a,{title:t.formatMessage(k.reject),icon:"times",onClick:c}))))},t}(O.a),Object(j.a)(c,"propTypes",{account:g.a.map.isRequired,onAuthorize:_.a.func.isRequired,onReject:_.a.func.isRequired,intl:_.a.object.isRequired}),o=n))||o,L=a(26),S=Object(f.connect)(function(){var a=Object(y.d)();return function(e,t){return{account:a(e,t.id)}}},function(e,t){var a=t.id;return{onAuthorize:function(){e(Object(L.v)(a))},onReject:function(){e(Object(L.I)(a))}}})(A),T=a(889);a.d(t,"default",function(){return x});var U=Object(h.f)({heading:{id:"column.follow_requests",defaultMessage:"Follow requests"}}),x=Object(f.connect)(function(e){return{accountIds:e.getIn(["user_lists","follow_requests","items"]),hasMore:!!e.getIn(["user_lists","follow_requests","next"])}})(i=Object(h.g)((s=r=function(c){function e(){for(var e,t=arguments.length,a=new Array(t),o=0;o<t;o++)a[o]=arguments[o];return e=c.call.apply(c,[this].concat(a))||this,Object(j.a)(Object(l.a)(e),"handleLoadMore",b()(function(){e.props.dispatch(Object(L.x)())},300,{leading:!0})),e}Object(d.a)(e,c);var t=e.prototype;return t.componentWillMount=function(){this.props.dispatch(Object(L.B)())},t.render=function(){var e=this.props,t=e.intl,a=e.shouldUpdateScroll,o=e.accountIds,c=e.hasMore;if(!o)return Object(u.a)(M.a,{},void 0,Object(u.a)(w.a,{}));var n=Object(u.a)(h.b,{id:"empty_column.follow_requests",defaultMessage:"You don't have any follow requests yet. When you receive one, it will show up here."});return Object(u.a)(M.a,{icon:"users",heading:t.formatMessage(U.heading)},void 0,Object(u.a)(q.a,{}),Object(u.a)(T.a,{scrollKey:"follow_requests",onLoadMore:this.handleLoadMore,hasMore:c,shouldUpdateScroll:a,emptyMessage:n},void 0,o.map(function(e){return Object(u.a)(S,{id:e},e)})))},e}(O.a),Object(j.a)(r,"propTypes",{params:_.a.object.isRequired,dispatch:_.a.func.isRequired,shouldUpdateScroll:_.a.func,hasMore:_.a.bool,accountIds:g.a.list,intl:_.a.object.isRequired}),i=s))||i)||i}}]);
//# sourceMappingURL=follow_requests.js.map