(window.webpackJsonp=window.webpackJsonp||[]).push([[15],{684:function(e,t,a){"use strict";a.r(t),a.d(t,"default",function(){return q});var o,n,c,s=a(0),r=a(3),i=a(7),d=a(1),u=a(56),l=a.n(u),b=(a(2),a(24)),p=a(6),h=a(25),f=a(27),j=a.n(f),O=a(5),g=a.n(O),M=a(272),k=a(625),m=a(632),v=a(891),y=a(361),w=a(889),I=Object(p.f)({heading:{id:"column.blocks",defaultMessage:"Blocked users"}}),q=Object(b.connect)(function(e){return{accountIds:e.getIn(["user_lists","blocks","items"]),hasMore:!!e.getIn(["user_lists","blocks","next"])}})(o=Object(p.g)((c=n=function(n){function e(){for(var e,t=arguments.length,a=new Array(t),o=0;o<t;o++)a[o]=arguments[o];return e=n.call.apply(n,[this].concat(a))||this,Object(d.a)(Object(r.a)(e),"handleLoadMore",l()(function(){e.props.dispatch(Object(y.c)())},300,{leading:!0})),e}Object(i.a)(e,n);var t=e.prototype;return t.componentWillMount=function(){this.props.dispatch(Object(y.d)())},t.render=function(){var e=this.props,t=e.intl,a=e.accountIds,o=e.shouldUpdateScroll,n=e.hasMore;if(!a)return Object(s.a)(k.a,{},void 0,Object(s.a)(M.a,{}));var c=Object(s.a)(p.b,{id:"empty_column.blocks",defaultMessage:"You haven't blocked any users yet."});return Object(s.a)(k.a,{icon:"ban",heading:t.formatMessage(I.heading)},void 0,Object(s.a)(m.a,{}),Object(s.a)(w.a,{scrollKey:"blocks",onLoadMore:this.handleLoadMore,hasMore:n,shouldUpdateScroll:o,emptyMessage:c},void 0,a.map(function(e){return Object(s.a)(v.a,{id:e},e)})))},e}(h.a),Object(d.a)(n,"propTypes",{params:g.a.object.isRequired,dispatch:g.a.func.isRequired,shouldUpdateScroll:g.a.func,accountIds:j.a.list,hasMore:g.a.bool,intl:g.a.object.isRequired}),o=c))||o)||o}}]);
//# sourceMappingURL=blocks.js.map