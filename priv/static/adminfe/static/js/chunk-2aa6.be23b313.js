(window.webpackJsonp=window.webpackJsonp||[]).push([["chunk-2aa6"],{FtQ1:function(t,s,e){"use strict";e.r(s);var n=e("RIqP"),r=e.n(n),a=e("MVZn"),i=e.n(a),o=e("L2JU"),u=e("i7Kn"),c=e("ot3S"),l={name:"Statuses",components:{MultipleUsersMenu:u.a,Status:c.a},data:function(){return{selectedInstance:"",selectedUsers:[],page:1,pageSize:30}},computed:i()({loadingPeers:function(){return this.$store.state.peers.loading}},Object(o.b)(["instances","statuses"])),created:function(){},mounted:function(){this.$store.dispatch("FetchPeers")},methods:{handleFilterChange:function(t){this.page=1,this.$store.dispatch("FetchStatusesByInstance",{instance:t,page:this.page,pageSize:this.pageSize})},handleLoadMore:function(){this.page=this.page+1,this.$store.dispatch("FetchStatusesPageByInstance",{instance:this.selectedInstance,page:this.page,pageSize:this.pageSize})},clearSelection:function(){},handleStatusSelection:function(t){void 0===this.selectedUsers.find(function(s){return t.id===s.id})&&(this.selectedUsers=[].concat(r()(this.selectedUsers),[t]))}}},d=(e("QOJ7"),e("KHd+")),p=Object(d.a)(l,function(){var t=this,s=t.$createElement,e=t._self._c||s;return t.loadingPeers?t._e():e("div",{staticClass:"statuses-container"},[e("h1",[t._v("\n    "+t._s(t.$t("statuses.statuses"))+"\n  ")]),t._v(" "),e("div",{staticClass:"filter-container"},[e("el-select",{attrs:{placeholder:t.$t("statuses.instanceFilter"),"no-data-text":t.$t("statuses.noInstances"),filterable:""},on:{change:t.handleFilterChange},model:{value:t.selectedInstance,callback:function(s){t.selectedInstance=s},expression:"selectedInstance"}},t._l(t.instances,function(t,s){return e("el-option",{key:s,attrs:{label:t,value:t}})}),1),t._v(" "),e("multiple-users-menu",{attrs:{"selected-users":t.selectedUsers},on:{"apply-action":t.clearSelection}})],1),t._v(" "),t._l(t.statuses,function(s){return e("div",{key:s.id,staticClass:"status-container"},[e("status",{attrs:{status:s},on:{"status-selection":t.handleStatusSelection}})],1)}),t._v(" "),t.statuses.length>0?e("div",{staticClass:"statuses-pagination"},[e("el-button",{on:{click:t.handleLoadMore}},[t._v(t._s(t.$t("statuses.loadMore")))])],1):t._e()],2)},[],!1,null,null,null);p.options.__file="index.vue";s.default=p.exports},KmHg:function(t,s,e){},Kw8l:function(t,s,e){"use strict";var n=e("cRgN");e.n(n).a},NQWY:function(t,s,e){"use strict";var n=e("P+4G");e.n(n).a},"P+4G":function(t,s,e){},QOJ7:function(t,s,e){"use strict";var n=e("KmHg");e.n(n).a},RnhZ:function(t,s,e){var n={"./af":"K/tc","./af.js":"K/tc","./ar":"jnO4","./ar-dz":"o1bE","./ar-dz.js":"o1bE","./ar-kw":"Qj4J","./ar-kw.js":"Qj4J","./ar-ly":"HP3h","./ar-ly.js":"HP3h","./ar-ma":"CoRJ","./ar-ma.js":"CoRJ","./ar-sa":"gjCT","./ar-sa.js":"gjCT","./ar-tn":"bYM6","./ar-tn.js":"bYM6","./ar.js":"jnO4","./az":"SFxW","./az.js":"SFxW","./be":"H8ED","./be.js":"H8ED","./bg":"hKrs","./bg.js":"hKrs","./bm":"p/rL","./bm.js":"p/rL","./bn":"kEOa","./bn.js":"kEOa","./bo":"0mo+","./bo.js":"0mo+","./br":"aIdf","./br.js":"aIdf","./bs":"JVSJ","./bs.js":"JVSJ","./ca":"1xZ4","./ca.js":"1xZ4","./cs":"PA2r","./cs.js":"PA2r","./cv":"A+xa","./cv.js":"A+xa","./cy":"l5ep","./cy.js":"l5ep","./da":"DxQv","./da.js":"DxQv","./de":"tGlX","./de-at":"s+uk","./de-at.js":"s+uk","./de-ch":"u3GI","./de-ch.js":"u3GI","./de.js":"tGlX","./dv":"WYrj","./dv.js":"WYrj","./el":"jUeY","./el.js":"jUeY","./en-SG":"zavE","./en-SG.js":"zavE","./en-au":"Dmvi","./en-au.js":"Dmvi","./en-ca":"OIYi","./en-ca.js":"OIYi","./en-gb":"Oaa7","./en-gb.js":"Oaa7","./en-ie":"4dOw","./en-ie.js":"4dOw","./en-il":"czMo","./en-il.js":"czMo","./en-nz":"b1Dy","./en-nz.js":"b1Dy","./eo":"Zduo","./eo.js":"Zduo","./es":"iYuL","./es-do":"CjzT","./es-do.js":"CjzT","./es-us":"Vclq","./es-us.js":"Vclq","./es.js":"iYuL","./et":"7BjC","./et.js":"7BjC","./eu":"D/JM","./eu.js":"D/JM","./fa":"jfSC","./fa.js":"jfSC","./fi":"gekB","./fi.js":"gekB","./fo":"ByF4","./fo.js":"ByF4","./fr":"nyYc","./fr-ca":"2fjn","./fr-ca.js":"2fjn","./fr-ch":"Dkky","./fr-ch.js":"Dkky","./fr.js":"nyYc","./fy":"cRix","./fy.js":"cRix","./ga":"USCx","./ga.js":"USCx","./gd":"9rRi","./gd.js":"9rRi","./gl":"iEDd","./gl.js":"iEDd","./gom-latn":"DKr+","./gom-latn.js":"DKr+","./gu":"4MV3","./gu.js":"4MV3","./he":"x6pH","./he.js":"x6pH","./hi":"3E1r","./hi.js":"3E1r","./hr":"S6ln","./hr.js":"S6ln","./hu":"WxRl","./hu.js":"WxRl","./hy-am":"1rYy","./hy-am.js":"1rYy","./id":"UDhR","./id.js":"UDhR","./is":"BVg3","./is.js":"BVg3","./it":"bpih","./it-ch":"bxKX","./it-ch.js":"bxKX","./it.js":"bpih","./ja":"B55N","./ja.js":"B55N","./jv":"tUCv","./jv.js":"tUCv","./ka":"IBtZ","./ka.js":"IBtZ","./kk":"bXm7","./kk.js":"bXm7","./km":"6B0Y","./km.js":"6B0Y","./kn":"PpIw","./kn.js":"PpIw","./ko":"Ivi+","./ko.js":"Ivi+","./ku":"JCF/","./ku.js":"JCF/","./ky":"lgnt","./ky.js":"lgnt","./lb":"RAwQ","./lb.js":"RAwQ","./lo":"sp3z","./lo.js":"sp3z","./lt":"JvlW","./lt.js":"JvlW","./lv":"uXwI","./lv.js":"uXwI","./me":"KTz0","./me.js":"KTz0","./mi":"aIsn","./mi.js":"aIsn","./mk":"aQkU","./mk.js":"aQkU","./ml":"AvvY","./ml.js":"AvvY","./mn":"lYtQ","./mn.js":"lYtQ","./mr":"Ob0Z","./mr.js":"Ob0Z","./ms":"6+QB","./ms-my":"ZAMP","./ms-my.js":"ZAMP","./ms.js":"6+QB","./mt":"G0Uy","./mt.js":"G0Uy","./my":"honF","./my.js":"honF","./nb":"bOMt","./nb.js":"bOMt","./ne":"OjkT","./ne.js":"OjkT","./nl":"+s0g","./nl-be":"2ykv","./nl-be.js":"2ykv","./nl.js":"+s0g","./nn":"uEye","./nn.js":"uEye","./pa-in":"8/+R","./pa-in.js":"8/+R","./pl":"jVdC","./pl.js":"jVdC","./pt":"8mBD","./pt-br":"0tRk","./pt-br.js":"0tRk","./pt.js":"8mBD","./ro":"lyxo","./ro.js":"lyxo","./ru":"lXzo","./ru.js":"lXzo","./sd":"Z4QM","./sd.js":"Z4QM","./se":"//9w","./se.js":"//9w","./si":"7aV9","./si.js":"7aV9","./sk":"e+ae","./sk.js":"e+ae","./sl":"gVVK","./sl.js":"gVVK","./sq":"yPMs","./sq.js":"yPMs","./sr":"zx6S","./sr-cyrl":"E+lV","./sr-cyrl.js":"E+lV","./sr.js":"zx6S","./ss":"Ur1D","./ss.js":"Ur1D","./sv":"X709","./sv.js":"X709","./sw":"dNwA","./sw.js":"dNwA","./ta":"PeUW","./ta.js":"PeUW","./te":"XLvN","./te.js":"XLvN","./tet":"V2x9","./tet.js":"V2x9","./tg":"Oxv6","./tg.js":"Oxv6","./th":"EOgW","./th.js":"EOgW","./tl-ph":"Dzi0","./tl-ph.js":"Dzi0","./tlh":"z3Vd","./tlh.js":"z3Vd","./tr":"DoHr","./tr.js":"DoHr","./tzl":"z1FC","./tzl.js":"z1FC","./tzm":"wQk9","./tzm-latn":"tT3J","./tzm-latn.js":"tT3J","./tzm.js":"wQk9","./ug-cn":"YRex","./ug-cn.js":"YRex","./uk":"raLr","./uk.js":"raLr","./ur":"UpQW","./ur.js":"UpQW","./uz":"Loxo","./uz-latn":"AQ68","./uz-latn.js":"AQ68","./uz.js":"Loxo","./vi":"KSF8","./vi.js":"KSF8","./x-pseudo":"/X5v","./x-pseudo.js":"/X5v","./yo":"fzPg","./yo.js":"fzPg","./zh-cn":"XDpg","./zh-cn.js":"XDpg","./zh-hk":"SatO","./zh-hk.js":"SatO","./zh-tw":"kOpN","./zh-tw.js":"kOpN"};function r(t){var s=a(t);return e(s)}function a(t){if(!e.o(n,t)){var s=new Error("Cannot find module '"+t+"'");throw s.code="MODULE_NOT_FOUND",s}return n[t]}r.keys=function(){return Object.keys(n)},r.resolve=a,t.exports=r,r.id="RnhZ"},cRgN:function(t,s,e){},i7Kn:function(t,s,e){"use strict";var n=e("o0o1"),r=e.n(n),a=e("yXPU"),i=e.n(a),o={props:{selectedUsers:{type:Array,default:function(){return[]}}},computed:{showDropdownForMultipleUsers:function(){return this.$props.selectedUsers.length>0},isDesktop:function(){return"desktop"===this.$store.state.app.device}},methods:{mappers:function(){var t=this,s=function(){var s=i()(r.a.mark(function s(e,n){return r.a.wrap(function(s){for(;;)switch(s.prev=s.next){case 0:return s.next=2,n(e);case 2:t.$emit("apply-action");case 3:case"end":return s.stop()}},s)}));return function(t,e){return s.apply(this,arguments)}}();return{grantRight:function(e){return function(){var n=function(){var s=i()(r.a.mark(function s(n){return r.a.wrap(function(s){for(;;)switch(s.prev=s.next){case 0:return s.next=2,t.$store.dispatch("AddRight",{users:n,right:e});case 2:return s.abrupt("return",s.sent);case 3:case"end":return s.stop()}},s)}));return function(t){return s.apply(this,arguments)}}(),a=t.selectedUsers.filter(function(s){return s.local&&!s.roles[e]&&t.$store.state.user.id!==s.id});s(a,n)}},revokeRight:function(e){return function(){var n=function(){var s=i()(r.a.mark(function s(n){return r.a.wrap(function(s){for(;;)switch(s.prev=s.next){case 0:return s.next=2,t.$store.dispatch("DeleteRight",{users:n,right:e});case 2:return s.abrupt("return",s.sent);case 3:case"end":return s.stop()}},s)}));return function(t){return s.apply(this,arguments)}}(),a=t.selectedUsers.filter(function(s){return s.local&&s.roles[e]&&t.$store.state.user.id!==s.id});s(a,n)}},activate:function(){var e=t.selectedUsers.filter(function(s){return s.deactivated&&t.$store.state.user.id!==s.id});s(e,function(){var s=i()(r.a.mark(function s(e){return r.a.wrap(function(s){for(;;)switch(s.prev=s.next){case 0:return s.next=2,t.$store.dispatch("ActivateUsers",e);case 2:return s.abrupt("return",s.sent);case 3:case"end":return s.stop()}},s)}));return function(t){return s.apply(this,arguments)}}())},deactivate:function(){var e=t.selectedUsers.filter(function(s){return!s.deactivated&&t.$store.state.user.id!==s.id});s(e,function(){var s=i()(r.a.mark(function s(e){return r.a.wrap(function(s){for(;;)switch(s.prev=s.next){case 0:return s.next=2,t.$store.dispatch("DeactivateUsers",e);case 2:return s.abrupt("return",s.sent);case 3:case"end":return s.stop()}},s)}));return function(t){return s.apply(this,arguments)}}())},remove:function(){var e=t.selectedUsers.filter(function(s){return t.$store.state.user.id!==s.id});s(e,function(){var s=i()(r.a.mark(function s(e){return r.a.wrap(function(s){for(;;)switch(s.prev=s.next){case 0:return s.next=2,t.$store.dispatch("DeleteUsers",e);case 2:return s.abrupt("return",s.sent);case 3:case"end":return s.stop()}},s)}));return function(t){return s.apply(this,arguments)}}())},addTag:function(e){return function(){var n=t.selectedUsers.filter(function(t){return"disable_remote_subscription"===e||"disable_any_subscription"===e?t.local&&!t.tags.includes(e):!t.tags.includes(e)});s(n,function(){var s=i()(r.a.mark(function s(n){return r.a.wrap(function(s){for(;;)switch(s.prev=s.next){case 0:return s.next=2,t.$store.dispatch("AddTag",{users:n,tag:e});case 2:return s.abrupt("return",s.sent);case 3:case"end":return s.stop()}},s)}));return function(t){return s.apply(this,arguments)}}())}},removeTag:function(e){return i()(r.a.mark(function n(){var a;return r.a.wrap(function(n){for(;;)switch(n.prev=n.next){case 0:a=t.selectedUsers.filter(function(t){return"disable_remote_subscription"===e||"disable_any_subscription"===e?t.local&&t.tags.includes(e):t.tags.includes(e)}),s(a,function(){var s=i()(r.a.mark(function s(n){return r.a.wrap(function(s){for(;;)switch(s.prev=s.next){case 0:return s.next=2,t.$store.dispatch("RemoveTag",{users:n,tag:e});case 2:return s.abrupt("return",s.sent);case 3:case"end":return s.stop()}},s)}));return function(t){return s.apply(this,arguments)}}());case 3:case"end":return n.stop()}},n)}))},requirePasswordReset:function(){t.selectedUsers.filter(function(t){return t.local}).map(function(s){return t.$store.dispatch("RequirePasswordReset",s)}),t.$emit("apply-action")},confirmAccounts:function(){var e=t.selectedUsers.filter(function(t){return t.local&&t.confirmation_pending});s(e,function(){var s=i()(r.a.mark(function s(e){return r.a.wrap(function(s){for(;;)switch(s.prev=s.next){case 0:return s.next=2,t.$store.dispatch("ConfirmUsersEmail",e);case 2:return s.abrupt("return",s.sent);case 3:case"end":return s.stop()}},s)}));return function(t){return s.apply(this,arguments)}}())},resendConfirmation:function(){var e=t.selectedUsers.filter(function(t){return t.local&&t.confirmation_pending});s(e,function(){var s=i()(r.a.mark(function s(e){return r.a.wrap(function(s){for(;;)switch(s.prev=s.next){case 0:return s.next=2,t.$store.dispatch("ResendConfirmationEmail",e);case 2:return s.abrupt("return",s.sent);case 3:case"end":return s.stop()}},s)}));return function(t){return s.apply(this,arguments)}}())}}},grantRightToMultipleUsers:function(t){var s=this.mappers().grantRight;this.confirmMessage(this.$t("users.grantRightConfirmation",{right:t}),s(t))},revokeRightFromMultipleUsers:function(t){var s=this.mappers().revokeRight;this.confirmMessage(this.$t("users.revokeRightConfirmation",{right:t}),s(t))},activateMultipleUsers:function(){var t=this.mappers().activate;this.confirmMessage(this.$t("users.activateMultipleUsersConfirmation"),t)},deactivateMultipleUsers:function(){var t=this.mappers().deactivate;this.confirmMessage(this.$t("users.deactivateMultipleUsersConfirmation"),t)},deleteMultipleUsers:function(){var t=this.mappers().remove;this.confirmMessage(this.$t("users.deleteMultipleUsersConfirmation"),t)},requirePasswordReset:function(){if(this.$store.state.user.nodeInfo.metadata.mailerEnabled){var t=this.mappers().requirePasswordReset;this.confirmMessage(this.$t("users.requirePasswordResetConfirmation"),t)}else this.$alert(this.$t("users.mailerMustBeEnabled"),"Error",{type:"error"})},addTagForMultipleUsers:function(t){var s=this.mappers().addTag;this.confirmMessage(this.$t("users.addTagForMultipleUsersConfirmation"),s(t))},removeTagFromMultipleUsers:function(t){var s=this.mappers().removeTag;this.confirmMessage(this.$t("users.removeTagFromMultipleUsersConfirmation"),s(t))},confirmAccountsForMultipleUsers:function(){var t=this.mappers().confirmAccounts;this.confirmMessage(this.$t("users.confirmAccountsConfirmation"),t)},resendConfirmationForMultipleUsers:function(){var t=this.mappers().resendConfirmation;this.confirmMessage(this.$t("users.resendEmailConfirmation"),t)},confirmMessage:function(t,s){var e=this;this.$confirm(t,{confirmButtonText:this.$t("users.ok"),cancelButtonText:this.$t("users.cancel"),type:"warning"}).then(function(){s()}).catch(function(){e.$message({type:"info",message:e.$t("users.canceled")})})}}},u=(e("NQWY"),e("KHd+")),c=Object(u.a)(o,function(){var t=this,s=t.$createElement,e=t._self._c||s;return e("el-dropdown",{attrs:{size:"small",trigger:"click",placement:"bottom-start"}},[t.isDesktop?e("el-button",{staticClass:"actions-button"},[e("span",{staticClass:"actions-button-container"},[e("span",[e("i",{staticClass:"el-icon-edit"}),t._v("\n        "+t._s(t.$t("users.moderateUsers"))+"\n      ")]),t._v(" "),e("i",{staticClass:"el-icon-arrow-down el-icon--right"})])]):t._e(),t._v(" "),t.showDropdownForMultipleUsers?e("el-dropdown-menu",{attrs:{slot:"dropdown"},slot:"dropdown"},[e("el-dropdown-item",{nativeOn:{click:function(s){return t.grantRightToMultipleUsers("admin")}}},[t._v("\n      "+t._s(t.$t("users.grantAdmin"))+"\n    ")]),t._v(" "),e("el-dropdown-item",{nativeOn:{click:function(s){return t.revokeRightFromMultipleUsers("admin")}}},[t._v("\n      "+t._s(t.$t("users.revokeAdmin"))+"\n    ")]),t._v(" "),e("el-dropdown-item",{nativeOn:{click:function(s){return t.grantRightToMultipleUsers("moderator")}}},[t._v("\n      "+t._s(t.$t("users.grantModerator"))+"\n    ")]),t._v(" "),e("el-dropdown-item",{nativeOn:{click:function(s){return t.revokeRightFromMultipleUsers("moderator")}}},[t._v("\n      "+t._s(t.$t("users.revokeModerator"))+"\n    ")]),t._v(" "),e("el-dropdown-item",{attrs:{divided:""},nativeOn:{click:function(s){return t.confirmAccountsForMultipleUsers(s)}}},[t._v("\n      "+t._s(t.$t("users.confirmAccounts"))+"\n    ")]),t._v(" "),e("el-dropdown-item",{nativeOn:{click:function(s){return t.resendConfirmationForMultipleUsers(s)}}},[t._v("\n      "+t._s(t.$t("users.resendConfirmation"))+"\n    ")]),t._v(" "),e("el-dropdown-item",{attrs:{divided:""},nativeOn:{click:function(s){return t.activateMultipleUsers(s)}}},[t._v("\n      "+t._s(t.$t("users.activateAccounts"))+"\n    ")]),t._v(" "),e("el-dropdown-item",{nativeOn:{click:function(s){return t.deactivateMultipleUsers(s)}}},[t._v("\n      "+t._s(t.$t("users.deactivateAccounts"))+"\n    ")]),t._v(" "),e("el-dropdown-item",{nativeOn:{click:function(s){return t.deleteMultipleUsers(s)}}},[t._v("\n      "+t._s(t.$t("users.deleteAccounts"))+"\n    ")]),t._v(" "),e("el-dropdown-item",{nativeOn:{click:function(s){return t.requirePasswordReset(s)}}},[t._v("\n      "+t._s(t.$t("users.requirePasswordReset"))+"\n    ")]),t._v(" "),e("el-dropdown-item",{staticClass:"no-hover",attrs:{divided:""}},[e("div",{staticClass:"tag-container"},[e("span",{staticClass:"tag-text"},[t._v(t._s(t.$t("users.forceNsfw")))]),t._v(" "),e("el-button-group",{staticClass:"tag-button-group"},[e("el-button",{attrs:{size:"mini"},nativeOn:{click:function(s){return t.addTagForMultipleUsers("force_nsfw")}}},[t._v("\n            "+t._s(t.$t("users.apply"))+"\n          ")]),t._v(" "),e("el-button",{attrs:{size:"mini"},nativeOn:{click:function(s){return t.removeTagFromMultipleUsers("force_nsfw")}}},[t._v("\n            "+t._s(t.$t("users.remove"))+"\n          ")])],1)],1)]),t._v(" "),e("el-dropdown-item",{staticClass:"no-hover"},[e("div",{staticClass:"tag-container"},[e("span",{staticClass:"tag-text"},[t._v(t._s(t.$t("users.stripMedia")))]),t._v(" "),e("el-button-group",{staticClass:"tag-button-group"},[e("el-button",{attrs:{size:"mini"},nativeOn:{click:function(s){return t.addTagForMultipleUsers("strip_media")}}},[t._v("\n            "+t._s(t.$t("users.apply"))+"\n          ")]),t._v(" "),e("el-button",{attrs:{size:"mini"},nativeOn:{click:function(s){return t.removeTagFromMultipleUsers("strip_media")}}},[t._v("\n            "+t._s(t.$t("users.remove"))+"\n          ")])],1)],1)]),t._v(" "),e("el-dropdown-item",{staticClass:"no-hover"},[e("div",{staticClass:"tag-container"},[e("span",{staticClass:"tag-text"},[t._v(t._s(t.$t("users.forceUnlisted")))]),t._v(" "),e("el-button-group",{staticClass:"tag-button-group"},[e("el-button",{attrs:{size:"mini"},nativeOn:{click:function(s){return t.addTagForMultipleUsers("force_unlisted")}}},[t._v("\n            "+t._s(t.$t("users.apply"))+"\n          ")]),t._v(" "),e("el-button",{attrs:{size:"mini"},nativeOn:{click:function(s){return t.removeTagFromMultipleUsers("force_unlisted")}}},[t._v("\n            "+t._s(t.$t("users.remove"))+"\n          ")])],1)],1)]),t._v(" "),e("el-dropdown-item",{staticClass:"no-hover"},[e("div",{staticClass:"tag-container"},[e("span",{staticClass:"tag-text"},[t._v(t._s(t.$t("users.sandbox")))]),t._v(" "),e("el-button-group",{staticClass:"tag-button-group"},[e("el-button",{attrs:{size:"mini"},nativeOn:{click:function(s){return t.addTagForMultipleUsers("sandbox")}}},[t._v("\n            "+t._s(t.$t("users.apply"))+"\n          ")]),t._v(" "),e("el-button",{attrs:{size:"mini"},nativeOn:{click:function(s){return t.removeTagFromMultipleUsers("sandbox")}}},[t._v("\n            "+t._s(t.$t("users.remove"))+"\n          ")])],1)],1)]),t._v(" "),e("el-dropdown-item",{staticClass:"no-hover"},[e("div",{staticClass:"tag-container"},[e("span",{staticClass:"tag-text"},[t._v(t._s(t.$t("users.disableRemoteSubscriptionForMultiple")))]),t._v(" "),e("el-button-group",{staticClass:"tag-button-group"},[e("el-button",{attrs:{size:"mini"},nativeOn:{click:function(s){return t.addTagForMultipleUsers("disable_remote_subscription")}}},[t._v("\n            "+t._s(t.$t("users.apply"))+"\n          ")]),t._v(" "),e("el-button",{attrs:{size:"mini"},nativeOn:{click:function(s){return t.removeTagFromMultipleUsers("disable_remote_subscription")}}},[t._v("\n            "+t._s(t.$t("users.remove"))+"\n          ")])],1)],1)]),t._v(" "),e("el-dropdown-item",{staticClass:"no-hover"},[e("div",{staticClass:"tag-container"},[e("span",{staticClass:"tag-text"},[t._v(t._s(t.$t("users.disableAnySubscriptionForMultiple")))]),t._v(" "),e("el-button-group",{staticClass:"tag-button-group"},[e("el-button",{attrs:{size:"mini"},nativeOn:{click:function(s){return t.addTagForMultipleUsers("disable_any_subscription")}}},[t._v("\n            "+t._s(t.$t("users.apply"))+"\n          ")]),t._v(" "),e("el-button",{attrs:{size:"mini"},nativeOn:{click:function(s){return t.removeTagFromMultipleUsers("disable_any_subscription")}}},[t._v("\n            "+t._s(t.$t("users.remove"))+"\n          ")])],1)],1)])],1):e("el-dropdown-menu",{attrs:{slot:"dropdown"},slot:"dropdown"},[e("el-dropdown-item",[t._v("\n      "+t._s(t.$t("users.selectUsers"))+"\n    ")])],1)],1)},[],!1,null,"56aa3725",null);c.options.__file="MultipleUsersMenu.vue";s.a=c.exports},ot3S:function(t,s,e){"use strict";var n=e("wd/R"),r=e.n(n),a={name:"Status",props:{status:{type:Object,required:!0},page:{type:Number,required:!1,default:0},userId:{type:String,required:!1,default:""},godmode:{type:Boolean,required:!1,default:!1}},data:function(){return{showHiddenStatus:!1}},methods:{capitalizeFirstLetter:function(t){return t.charAt(0).toUpperCase()+t.slice(1)},changeStatus:function(t,s,e){this.$store.dispatch("ChangeStatusScope",{statusId:t,isSensitive:s,visibility:e,reportCurrentPage:this.page,userId:this.userId,godmode:this.godmode})},deleteStatus:function(t){var s=this;this.$confirm("Are you sure you want to delete this status?","Warning",{confirmButtonText:"OK",cancelButtonText:"Cancel",type:"warning"}).then(function(){s.$store.dispatch("DeleteStatus",{statusId:t,reportCurrentPage:s.page,userId:s.userId,godmode:s.godmode}),s.$message({type:"success",message:"Delete completed"})}).catch(function(){s.$message({type:"info",message:"Delete canceled"})})},optionPercent:function(t,s){var e=t.options.reduce(function(t,s){return t+s.votes_count},0);return 0===e?0:+(s.votes_count/e*100).toFixed(1)},parseTimestamp:function(t){return r()(t).format("YYYY-MM-DD HH:mm")},handleStatusSelection:function(t){this.$emit("status-selection",t)}}},i=(e("Kw8l"),e("KHd+")),o=Object(i.a)(a,function(){var t=this,s=t.$createElement,e=t._self._c||s;return e("div",[t.status.deleted?e("el-card",{staticClass:"status-card"},[e("div",{attrs:{slot:"header"},slot:"header"},[e("div",{staticClass:"status-header"},[e("div",{staticClass:"status-account-container"},[e("div",{staticClass:"status-account"},[e("h4",{staticClass:"status-deleted"},[t._v(t._s(t.$t("reports.statusDeleted")))])])])])]),t._v(" "),e("div",{staticClass:"status-body"},[t.status.content?e("span",{staticClass:"status-content",domProps:{innerHTML:t._s(t.status.content)}}):e("span",{staticClass:"status-without-content"},[t._v("no content")])]),t._v(" "),t.status.created_at?e("a",{staticClass:"account",attrs:{href:t.status.url,target:"_blank"}},[t._v("\n      "+t._s(t.parseTimestamp(t.status.created_at))+"\n    ")]):t._e()]):e("el-card",{staticClass:"status-card"},[e("div",{attrs:{slot:"header"},slot:"header"},[e("div",{staticClass:"status-header"},[e("div",{staticClass:"status-account-container"},[e("div",{staticClass:"status-account"},[e("el-checkbox",{on:{change:function(s){return t.handleStatusSelection(t.status.account)}}},[e("img",{staticClass:"status-avatar-img",attrs:{src:t.status.account.avatar}}),t._v(" "),e("h3",{staticClass:"status-account-name"},[t._v(t._s(t.status.account.display_name))])])],1),t._v(" "),e("a",{staticClass:"account",attrs:{href:t.status.account.url,target:"_blank"}},[t._v("\n            @"+t._s(t.status.account.acct)+"\n          ")])]),t._v(" "),e("div",{staticClass:"status-actions"},[t.status.sensitive?e("el-tag",{attrs:{type:"warning",size:"large"}},[t._v(t._s(t.$t("reports.sensitive")))]):t._e(),t._v(" "),e("el-tag",{attrs:{size:"large"}},[t._v(t._s(t.capitalizeFirstLetter(t.status.visibility)))]),t._v(" "),e("el-dropdown",{attrs:{trigger:"click"}},[e("el-button",{staticClass:"status-actions-button",attrs:{plain:"",size:"small",icon:"el-icon-edit"}},[t._v("\n              "+t._s(t.$t("reports.changeScope"))),e("i",{staticClass:"el-icon-arrow-down el-icon--right"})]),t._v(" "),e("el-dropdown-menu",{attrs:{slot:"dropdown"},slot:"dropdown"},[t.status.sensitive?t._e():e("el-dropdown-item",{nativeOn:{click:function(s){return t.changeStatus(t.status.id,!0,t.status.visibility)}}},[t._v("\n                "+t._s(t.$t("reports.addSensitive"))+"\n              ")]),t._v(" "),t.status.sensitive?e("el-dropdown-item",{nativeOn:{click:function(s){return t.changeStatus(t.status.id,!1,t.status.visibility)}}},[t._v("\n                "+t._s(t.$t("reports.removeSensitive"))+"\n              ")]):t._e(),t._v(" "),"public"!==t.status.visibility?e("el-dropdown-item",{nativeOn:{click:function(s){return t.changeStatus(t.status.id,t.status.sensitive,"public")}}},[t._v("\n                "+t._s(t.$t("reports.public"))+"\n              ")]):t._e(),t._v(" "),"private"!==t.status.visibility?e("el-dropdown-item",{nativeOn:{click:function(s){return t.changeStatus(t.status.id,t.status.sensitive,"private")}}},[t._v("\n                "+t._s(t.$t("reports.private"))+"\n              ")]):t._e(),t._v(" "),"unlisted"!==t.status.visibility?e("el-dropdown-item",{nativeOn:{click:function(s){return t.changeStatus(t.status.id,t.status.sensitive,"unlisted")}}},[t._v("\n                "+t._s(t.$t("reports.unlisted"))+"\n              ")]):t._e(),t._v(" "),e("el-dropdown-item",{nativeOn:{click:function(s){return t.deleteStatus(t.status.id)}}},[t._v("\n                "+t._s(t.$t("reports.deleteStatus"))+"\n              ")])],1)],1)],1)])]),t._v(" "),e("div",{staticClass:"status-body"},[t.status.spoiler_text?e("div",[e("strong",[t._v(t._s(t.status.spoiler_text))]),t._v(" "),t.showHiddenStatus?t._e():e("el-button",{staticClass:"show-more-button",attrs:{size:"mini"},on:{click:function(s){t.showHiddenStatus=!0}}},[t._v("Show more")]),t._v(" "),t.showHiddenStatus?e("el-button",{staticClass:"show-more-button",attrs:{size:"mini"},on:{click:function(s){t.showHiddenStatus=!1}}},[t._v("Show less")]):t._e(),t._v(" "),t.showHiddenStatus?e("div",[e("span",{staticClass:"status-content",domProps:{innerHTML:t._s(t.status.content)}}),t._v(" "),t.status.poll?e("div",{staticClass:"poll"},[e("ul",t._l(t.status.poll.options,function(s,n){return e("li",{key:n},[t._v("\n                "+t._s(s.title)+"\n                "),e("el-progress",{attrs:{percentage:t.optionPercent(t.status.poll,s)}})],1)}),0)]):t._e(),t._v(" "),t._l(t.status.media_attachments,function(t,s){return e("div",{key:s,staticClass:"image"},[e("img",{attrs:{src:t.preview_url}})])})],2):t._e()],1):t._e(),t._v(" "),t.status.spoiler_text?t._e():e("div",[e("span",{staticClass:"status-content",domProps:{innerHTML:t._s(t.status.content)}}),t._v(" "),t.status.poll?e("div",{staticClass:"poll"},[e("ul",t._l(t.status.poll.options,function(s,n){return e("li",{key:n},[t._v("\n              "+t._s(s.title)+"\n              "),e("el-progress",{attrs:{percentage:t.optionPercent(t.status.poll,s)}})],1)}),0)]):t._e(),t._v(" "),t._l(t.status.media_attachments,function(t,s){return e("div",{key:s,staticClass:"image"},[e("img",{attrs:{src:t.preview_url}})])})],2),t._v(" "),e("a",{staticClass:"account",attrs:{href:t.status.url,target:"_blank"}},[t._v("\n        "+t._s(t.parseTimestamp(t.status.created_at))+"\n      ")])])])],1)},[],!1,null,null,null);o.options.__file="index.vue";s.a=o.exports}}]);
//# sourceMappingURL=chunk-2aa6.be23b313.js.map