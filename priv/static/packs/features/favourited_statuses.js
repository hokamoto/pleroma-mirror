(window.webpackJsonp=window.webpackJsonp||[]).push([[19],{694:function(t,e,a){"use strict";a.r(e),a.d(e,"default",function(){return C});var o,n,s,r=a(1),i=a(6),c=a(0),u=a(2),l=a(54),d=a.n(l),h=a(3),b=a.n(h),p=a(20),f=a(5),j=a.n(f),O=a(26),g=a.n(O),m=a(165),v=a(641),M=a(429),I=a(206),w=a(648),y=a(7),L=a(24),k=Object(y.f)({heading:{id:"column.favourites",defaultMessage:"Favourites"}}),C=Object(p.connect)(function(t){return{statusIds:t.getIn(["status_lists","favourites","items"]),isLoading:t.getIn(["status_lists","favourites","isLoading"],!0),hasMore:!!t.getIn(["status_lists","favourites","next"])}})(o=Object(y.g)((s=n=function(n){function t(){for(var o,t=arguments.length,e=new Array(t),a=0;a<t;a++)e[a]=arguments[a];return o=n.call.apply(n,[this].concat(e))||this,Object(u.a)(Object(c.a)(Object(c.a)(o)),"handlePin",function(){var t=o.props,e=t.columnId,a=t.dispatch;a(e?Object(I.h)(e):Object(I.e)("FAVOURITES",{}))}),Object(u.a)(Object(c.a)(Object(c.a)(o)),"handleMove",function(t){var e=o.props,a=e.columnId;(0,e.dispatch)(Object(I.g)(a,t))}),Object(u.a)(Object(c.a)(Object(c.a)(o)),"handleHeaderClick",function(){o.column.scrollTop()}),Object(u.a)(Object(c.a)(Object(c.a)(o)),"setRef",function(t){o.column=t}),Object(u.a)(Object(c.a)(Object(c.a)(o)),"handleLoadMore",d()(function(){o.props.dispatch(Object(m.g)())},300,{leading:!0})),o}Object(i.a)(t,n);var e=t.prototype;return e.componentWillMount=function(){this.props.dispatch(Object(m.h)())},e.render=function(){var t=this.props,e=t.intl,a=t.shouldUpdateScroll,o=t.statusIds,n=t.columnId,s=t.multiColumn,i=t.hasMore,c=t.isLoading,u=!!n,l=Object(r.a)(y.b,{id:"empty_column.favourited_statuses",defaultMessage:"You don't have any favourite toots yet. When you favourite one, it will show up here."});return b.a.createElement(v.a,{ref:this.setRef,label:e.formatMessage(k.heading)},Object(r.a)(M.a,{icon:"star",title:e.formatMessage(k.heading),onPin:this.handlePin,onMove:this.handleMove,onClick:this.handleHeaderClick,pinned:u,multiColumn:s,showBackButton:!0}),Object(r.a)(w.a,{trackScroll:!u,statusIds:o,scrollKey:"favourited_statuses-"+n,hasMore:i,isLoading:c,onLoadMore:this.handleLoadMore,shouldUpdateScroll:a,emptyMessage:l}))},t}(L.a),Object(u.a)(n,"propTypes",{dispatch:j.a.func.isRequired,shouldUpdateScroll:j.a.func,statusIds:g.a.list.isRequired,intl:j.a.object.isRequired,columnId:j.a.string,multiColumn:j.a.bool,hasMore:j.a.bool,isLoading:j.a.bool}),o=s))||o)||o}}]);
//# sourceMappingURL=favourited_statuses.js.map