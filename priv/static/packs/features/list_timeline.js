(window.webpackJsonp=window.webpackJsonp||[]).push([[33],{672:function(e,t,a){"use strict";a.r(t),a.d(t,"default",function(){return D});var n,i,s,d=a(0),c=a(3),o=a(7),l=a(1),r=a(2),p=a.n(r),b=a(24),u=a(5),h=a.n(u),m=a(898),O=a(631),j=a(628),f=a(627),v=a(223),g=a(6),M=a(634),C=a(35),I=a(32),y=a(57),k=a(910),_=a(272),w=a(30),x=Object(g.f)({deleteMessage:{id:"confirmations.delete_list.message",defaultMessage:"Are you sure you want to permanently delete this list?"},deleteConfirm:{id:"confirmations.delete_list.confirm",defaultMessage:"Delete"}}),D=Object(b.connect)(function(e,t){return{list:e.getIn(["lists",t.params.id]),hasUnread:0<e.getIn(["timelines","list:"+t.params.id,"unread"])}})(n=Object(g.g)((s=i=function(n){function e(){for(var s,e=arguments.length,t=new Array(e),a=0;a<e;a++)t[a]=arguments[a];return s=n.call.apply(n,[this].concat(t))||this,Object(l.a)(Object(c.a)(s),"handlePin",function(){var e=s.props,t=e.columnId,a=e.dispatch;t?a(Object(v.h)(t)):(a(Object(v.e)("LIST",{id:s.props.params.id})),s.context.router.history.push("/"))}),Object(l.a)(Object(c.a)(s),"handleMove",function(e){var t=s.props,a=t.columnId;(0,t.dispatch)(Object(v.g)(a,e))}),Object(l.a)(Object(c.a)(s),"handleHeaderClick",function(){s.column.scrollTop()}),Object(l.a)(Object(c.a)(s),"setRef",function(e){s.column=e}),Object(l.a)(Object(c.a)(s),"handleLoadMore",function(e){var t=s.props.params.id;s.props.dispatch(Object(C.t)(t,{maxId:e}))}),Object(l.a)(Object(c.a)(s),"handleEditClick",function(){s.props.dispatch(Object(y.d)("LIST_EDITOR",{listId:s.props.params.id}))}),Object(l.a)(Object(c.a)(s),"handleDeleteClick",function(){var e=s.props,t=e.dispatch,a=e.columnId,n=e.intl,i=s.props.params.id;t(Object(y.d)("CONFIRM",{message:n.formatMessage(x.deleteMessage),confirm:n.formatMessage(x.deleteConfirm),onConfirm:function(){t(Object(I.F)(i)),a?t(Object(v.h)(a)):s.context.router.history.push("/lists")}}))}),s}Object(o.a)(e,n);var t=e.prototype;return t.componentDidMount=function(){var e=this.props.dispatch,t=this.props.params.id;e(Object(I.G)(t)),e(Object(C.t)(t)),this.disconnect=e(Object(M.d)(t))},t.componentWillUnmount=function(){this.disconnect&&(this.disconnect(),this.disconnect=null)},t.render=function(){var e=this.props,t=e.shouldUpdateScroll,a=e.hasUnread,n=e.columnId,i=e.multiColumn,s=e.list,c=this.props.params.id,o=!!n,l=s?s.get("title"):c;return void 0===s?Object(d.a)(O.a,{},void 0,Object(d.a)("div",{className:"scrollable"},void 0,Object(d.a)(_.a,{}))):!1===s?Object(d.a)(O.a,{},void 0,Object(d.a)(j.a,{}),Object(d.a)(k.a,{})):p.a.createElement(O.a,{ref:this.setRef,label:l},Object(d.a)(f.a,{icon:"list-ul",active:a,title:l,onPin:this.handlePin,onMove:this.handleMove,onClick:this.handleHeaderClick,pinned:o,multiColumn:i},void 0,Object(d.a)("div",{className:"column-header__links"},void 0,Object(d.a)("button",{className:"text-btn column-header__setting-btn",tabIndex:"0",onClick:this.handleEditClick},void 0,Object(d.a)(w.a,{id:"pencil"})," ",Object(d.a)(g.b,{id:"lists.edit",defaultMessage:"Edit list"})),Object(d.a)("button",{className:"text-btn column-header__setting-btn",tabIndex:"0",onClick:this.handleDeleteClick},void 0,Object(d.a)(w.a,{id:"trash"})," ",Object(d.a)(g.b,{id:"lists.delete",defaultMessage:"Delete list"}))),Object(d.a)("hr",{})),Object(d.a)(m.a,{trackScroll:!o,scrollKey:"list_timeline-"+n,timelineId:"list:"+c,onLoadMore:this.handleLoadMore,emptyMessage:Object(d.a)(g.b,{id:"empty_column.list",defaultMessage:"There is nothing in this list yet. When members of this list post new statuses, they will appear here."}),shouldUpdateScroll:t}))},e}(p.a.PureComponent),Object(l.a)(i,"contextTypes",{router:h.a.object}),n=s))||n)||n}}]);
//# sourceMappingURL=list_timeline.js.map