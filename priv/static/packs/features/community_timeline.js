(window.webpackJsonp=window.webpackJsonp||[]).push([[16],{715:function(e,t,n){"use strict";n.r(t);var o,i,c,d=n(0),a=n(2),l=n(6),s=n(1),r=n(3),u=n.n(r),m=n(21),p=n(7),h=n(5),b=n.n(h),y=n(904),f=n(633),j=n(628),M=n(35),O=n(222),g=n(987),v=n(70),I=Object(m.connect)(function(e,t){var n=t.columnId,o=e.getIn(["settings","columns"]),i=o.findIndex(function(e){return e.get("uuid")===n});return{settings:n&&0<=i?o.get(i).get("params"):e.getIn(["settings","community"])}},function(n,e){var o=e.columnId;return{onChange:function(e,t){n(o?Object(O.f)(o,e,t):Object(v.c)(["community"].concat(e),t))}}})(g.a),C=n(635);n.d(t,"default",function(){return U});var w=Object(p.f)({title:{id:"column.community",defaultMessage:"Local timeline"}}),U=Object(m.connect)(function(e,t){var n=t.onlyMedia,o=t.columnId,i=o,c=e.getIn(["settings","columns"]),a=c.findIndex(function(e){return e.get("uuid")===i});return{hasUnread:0<e.getIn(["timelines","community"+(n?":media":""),"unread"]),onlyMedia:o&&0<=a?c.get(a).getIn(["params","other","onlyMedia"]):e.getIn(["settings","community","other","onlyMedia"])}})(o=Object(p.g)((c=i=function(o){function e(){for(var i,e=arguments.length,t=new Array(e),n=0;n<e;n++)t[n]=arguments[n];return i=o.call.apply(o,[this].concat(t))||this,Object(s.a)(Object(a.a)(i),"handlePin",function(){var e=i.props,t=e.columnId,n=e.dispatch,o=e.onlyMedia;n(t?Object(O.h)(t):Object(O.e)("COMMUNITY",{other:{onlyMedia:o}}))}),Object(s.a)(Object(a.a)(i),"handleMove",function(e){var t=i.props,n=t.columnId;(0,t.dispatch)(Object(O.g)(n,e))}),Object(s.a)(Object(a.a)(i),"handleHeaderClick",function(){i.column.scrollTop()}),Object(s.a)(Object(a.a)(i),"setRef",function(e){i.column=e}),Object(s.a)(Object(a.a)(i),"handleLoadMore",function(e){var t=i.props,n=t.dispatch,o=t.onlyMedia;n(Object(M.q)({maxId:e,onlyMedia:o}))}),i}Object(l.a)(e,o);var t=e.prototype;return t.componentDidMount=function(){var e=this.props,t=e.dispatch,n=e.onlyMedia;t(Object(M.q)({onlyMedia:n})),this.disconnect=t(Object(C.a)({onlyMedia:n}))},t.componentDidUpdate=function(e){if(e.onlyMedia!==this.props.onlyMedia){var t=this.props,n=t.dispatch,o=t.onlyMedia;this.disconnect(),n(Object(M.q)({onlyMedia:o})),this.disconnect=n(Object(C.a)({onlyMedia:o}))}},t.componentWillUnmount=function(){this.disconnect&&(this.disconnect(),this.disconnect=null)},t.render=function(){var e=this.props,t=e.intl,n=e.shouldUpdateScroll,o=e.hasUnread,i=e.columnId,c=e.multiColumn,a=e.onlyMedia,l=!!i;return u.a.createElement(f.a,{ref:this.setRef,label:t.formatMessage(w.title)},Object(d.a)(j.a,{icon:"users",active:o,title:t.formatMessage(w.title),onPin:this.handlePin,onMove:this.handleMove,onClick:this.handleHeaderClick,pinned:l,multiColumn:c},void 0,Object(d.a)(I,{columnId:i})),Object(d.a)(y.a,{trackScroll:!l,scrollKey:"community_timeline-"+i,timelineId:"community"+(a?":media":""),onLoadMore:this.handleLoadMore,emptyMessage:Object(d.a)(p.b,{id:"empty_column.community",defaultMessage:"The local timeline is empty. Write something publicly to get the ball rolling!"}),shouldUpdateScroll:n}))},e}(u.a.PureComponent),Object(s.a)(i,"contextTypes",{router:b.a.object}),Object(s.a)(i,"defaultProps",{onlyMedia:!1}),o=c))||o)||o}}]);
//# sourceMappingURL=community_timeline.js.map