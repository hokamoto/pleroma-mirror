(window.webpackJsonp=window.webpackJsonp||[]).push([["chunk-f5e2"],{"/Z02":function(e,t,s){},"6eCR":function(e,t,s){"use strict";var r=s("Jdpf");s.n(r).a},"9/5/":function(e,t,s){(function(t){var s="Expected a function",r=NaN,n="[object Symbol]",i=/^\s+|\s+$/g,o=/^[-+]0x[0-9a-f]+$/i,a=/^0b[01]+$/i,c=/^0o[0-7]+$/i,u=parseInt,l="object"==typeof t&&t&&t.Object===Object&&t,d="object"==typeof self&&self&&self.Object===Object&&self,p=l||d||Function("return this")(),v=Object.prototype.toString,f=Math.max,m=Math.min,h=function(){return p.Date.now()};function _(e){var t=typeof e;return!!e&&("object"==t||"function"==t)}function g(e){if("number"==typeof e)return e;if(function(e){return"symbol"==typeof e||function(e){return!!e&&"object"==typeof e}(e)&&v.call(e)==n}(e))return r;if(_(e)){var t="function"==typeof e.valueOf?e.valueOf():e;e=_(t)?t+"":t}if("string"!=typeof e)return 0===e?e:+e;e=e.replace(i,"");var s=a.test(e);return s||c.test(e)?u(e.slice(2),s?2:8):o.test(e)?r:+e}e.exports=function(e,t,r){var n,i,o,a,c,u,l=0,d=!1,p=!1,v=!0;if("function"!=typeof e)throw new TypeError(s);function w(t){var s=n,r=i;return n=i=void 0,l=t,a=e.apply(r,s)}function $(e){var s=e-u;return void 0===u||s>=t||s<0||p&&e-l>=o}function b(){var e=h();if($(e))return k(e);c=setTimeout(b,function(e){var s=t-(e-u);return p?m(s,o-(e-l)):s}(e))}function k(e){return c=void 0,v&&n?w(e):(n=i=void 0,a)}function U(){var e=h(),s=$(e);if(n=arguments,i=this,u=e,s){if(void 0===c)return function(e){return l=e,c=setTimeout(b,t),d?w(e):a}(u);if(p)return c=setTimeout(b,t),w(u)}return void 0===c&&(c=setTimeout(b,t)),a}return t=g(t)||0,_(r)&&(d=!!r.leading,o=(p="maxWait"in r)?f(g(r.maxWait)||0,t):o,v="trailing"in r?!!r.trailing:v),U.cancel=function(){void 0!==c&&clearTimeout(c),l=0,n=u=i=c=void 0},U.flush=function(){return void 0===c?a:k(h())},U}}).call(this,s("yLpj"))},DPTh:function(e,t,s){"use strict";var r=s("vg5t");s.n(r).a},DVld:function(e,t,s){"use strict";var r=s("/Z02");s.n(r).a},Jdpf:function(e,t,s){},NQWY:function(e,t,s){"use strict";var r=s("P+4G");s.n(r).a},"P+4G":function(e,t,s){},RGjw:function(e,t,s){"use strict";s.r(t);var r=s("o0o1"),n=s.n(r),i=s("yXPU"),o=s.n(i),a=s("9/5/"),c=s.n(a),u=s("ZhIB"),l=s.n(u),d=s("lSNA"),p=s.n(d),v=s("MVZn"),f=s.n(v),m={data:function(){return{value:[]}},computed:{isDesktop:function(){return"desktop"===this.$store.state.app.device}},methods:{removeOppositeFilters:function(){var e=Object.keys(this.$store.state.users.filters).length,t=this.$data.value.slice(),s=t.indexOf("local"),r=t.indexOf("external"),n=t.indexOf("active"),i=t.indexOf("deactivated");if(t.length===e)return[];if(s>-1&&r>-1){var o=s>r?r:s;t.splice(o,1)}else if(n>-1&&i>-1){var a=n>i?i:n;t.splice(a,1)}return t},toggleFilters:function(){this.$data.value=this.removeOppositeFilters();var e=this.$data.value.reduce(function(e,t){return f()({},e,p()({},t,!0))},{});this.$store.dispatch("ToggleUsersFilter",e)}}},h=(s("DVld"),s("KHd+")),_=Object(h.a)(m,function(){var e=this,t=e.$createElement,s=e._self._c||t;return s("el-select",{staticClass:"select-field",attrs:{clearable:e.isDesktop,placeholder:e.$t("usersFilter.inputPlaceholder"),multiple:""},on:{change:e.toggleFilters},model:{value:e.value,callback:function(t){e.value=t},expression:"value"}},[s("el-option-group",{attrs:{label:e.$t("usersFilter.byUserType")}},[s("el-option",{attrs:{value:"local"}},[e._v(e._s(e.$t("usersFilter.local")))]),e._v(" "),s("el-option",{attrs:{value:"external"}},[e._v(e._s(e.$t("usersFilter.external")))])],1),e._v(" "),s("el-option-group",{attrs:{label:e.$t("usersFilter.byStatus")}},[s("el-option",{attrs:{value:"active"}},[e._v(e._s(e.$t("usersFilter.active")))]),e._v(" "),s("el-option",{attrs:{value:"deactivated"}},[e._v(e._s(e.$t("usersFilter.deactivated")))])],1)],1)},[],!1,null,"71bc6b38",null);_.options.__file="UsersFilter.vue";var g=_.exports,w=s("i7Kn"),$={name:"NewAccountDialog",props:{dialogFormVisible:{type:Boolean,default:function(){return!1}}},data:function(){return{newUserForm:{nickname:"",email:"",password:""},rules:{nickname:[{validator:this.validateUsername,trigger:"blur"}],email:[{validator:this.validateEmail,trigger:"blur"}],password:[{validator:this.validatePassword,trigger:"blur"}]}}},computed:{isDesktop:function(){return"desktop"===this.$store.state.app.device},isVisible:{get:function(){return this.$props.dialogFormVisible},set:function(){this.closeDialogWindow()}},getLabelWidth:function(){return this.isDesktop?"120px":"85px"}},methods:{closeDialogWindow:function(){this.$emit("closeWindow")},resetForm:function(){var e=this;this.$nextTick(function(){e.$refs.newUserForm.resetFields()})},submitForm:function(e){var t=this;this.$refs[e].validate(function(e){if(!e)return t.$message({type:"error",message:t.$t("users.submitFormError")}),!1;t.$emit("createNewAccount",t.$data.newUserForm)})},validateEmail:function(e,t,s){return""===t?s(new Error(this.$t("users.emptyEmailError"))):this.validEmail(t)?s():s(new Error(this.$t("users.invalidEmailError")))},validatePassword:function(e,t,s){return""===t?s(new Error(this.$t("users.emptyPasswordError"))):s()},validateUsername:function(e,t,s){return""===t?s(new Error(this.$t("users.emptyNicknameError"))):this.validNickname(t)?s():s(new Error(this.$t("users.invalidNicknameError")))},validEmail:function(e){return/^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/.test(e)},validNickname:function(e){return/^[a-zA-Z\d]+$/.test(e)}}},b=(s("DPTh"),Object(h.a)($,function(){var e=this,t=e.$createElement,s=e._self._c||t;return s("el-dialog",{attrs:{visible:e.isVisible,"show-close":!1,title:e.$t("users.createAccount"),"custom-class":"create-user-dialog"},on:{"update:visible":function(t){e.isVisible=t},open:e.resetForm}},[s("el-form",{ref:"newUserForm",attrs:{model:e.newUserForm,rules:e.rules,"label-width":e.getLabelWidth,"status-icon":""}},[s("el-form-item",{staticClass:"create-account-form-item",attrs:{label:e.$t("users.username"),prop:"nickname"}},[s("el-input",{attrs:{name:"nickname",autofocus:""},model:{value:e.newUserForm.nickname,callback:function(t){e.$set(e.newUserForm,"nickname",t)},expression:"newUserForm.nickname"}})],1),e._v(" "),s("el-form-item",{staticClass:"create-account-form-item",attrs:{label:e.$t("users.email"),prop:"email"}},[s("el-input",{attrs:{name:"email",type:"email"},model:{value:e.newUserForm.email,callback:function(t){e.$set(e.newUserForm,"email",t)},expression:"newUserForm.email"}})],1),e._v(" "),s("el-form-item",{staticClass:"create-account-form-item-without-margin",attrs:{label:e.$t("users.password"),prop:"password"}},[s("el-input",{attrs:{type:"password",name:"password",autocomplete:"off"},model:{value:e.newUserForm.password,callback:function(t){e.$set(e.newUserForm,"password",t)},expression:"newUserForm.password"}})],1)],1),e._v(" "),s("span",{attrs:{slot:"footer"},slot:"footer"},[s("el-button",{on:{click:e.closeDialogWindow}},[e._v(e._s(e.$t("users.cancel")))]),e._v(" "),s("el-button",{attrs:{type:"primary"},on:{click:function(t){return e.submitForm("newUserForm")}}},[e._v(e._s(e.$t("users.create")))])],1)],1)},[],!1,null,null,null));b.options.__file="NewAccountDialog.vue";var k=b.exports,U={name:"Users",components:{UsersFilter:g,MultipleUsersMenu:w.a,NewAccountDialog:k},data:function(){return{search:"",selectedUsers:[],createAccountDialogOpen:!1,resetPasswordDialogOpen:!1}},computed:{loading:function(){return this.$store.state.users.loading},normalizedUsersCount:function(){return l()(this.$store.state.users.totalUsersCount).format("0a")},users:function(){return this.$store.state.users.fetchedUsers},usersCount:function(){return this.$store.state.users.totalUsersCount},pageSize:function(){return this.$store.state.users.pageSize},passwordResetLink:function(){return this.$store.state.users.passwordResetToken.link},passwordResetToken:function(){return this.$store.state.users.passwordResetToken.token},currentPage:function(){return this.$store.state.users.currentPage},isDesktop:function(){return"desktop"===this.$store.state.app.device},isMobile:function(){return"mobile"===this.$store.state.app.device},width:function(){return!!this.isMobile&&55}},created:function(){var e=this;this.handleDebounceSearchInput=c()(function(t){e.$store.dispatch("SearchUsers",{query:t,page:1})},500)},mounted:function(){this.$store.dispatch("FetchUsers",{page:1})},methods:{activationIcon:function(e){return e?"el-icon-error":"el-icon-success"},clearSelection:function(){this.$refs.usersTable.clearSelection()},createNewAccount:function(){var e=o()(n.a.mark(function e(t){return n.a.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return e.next=2,this.$store.dispatch("CreateNewAccount",t);case 2:this.createAccountDialogOpen=!1;case 3:case"end":return e.stop()}},e,this)}));return function(t){return e.apply(this,arguments)}}(),getFirstLetter:function(e){return e.charAt(0).toUpperCase()},getPasswordResetToken:function(e){this.resetPasswordDialogOpen=!0,this.$store.dispatch("GetPasswordResetToken",e)},requirePasswordReset:function(e){this.$store.state.user.nodeInfo.metadata.mailerEnabled?this.$store.dispatch("RequirePasswordReset",{nickname:e}):this.$alert(this.$t("users.mailerMustBeEnabled"),"Error",{type:"error"})},toggleActivation:function(e){e.deactivated?this.$store.dispatch("ActivateUsers",[e]):this.$store.dispatch("DeactivateUsers",[e])},handleDeletion:function(e){this.$store.dispatch("DeleteUsers",[e])},handlePageChange:function(e){var t=this.$store.state.users.searchQuery;""===t?this.$store.dispatch("FetchUsers",{page:e}):this.$store.dispatch("SearchUsers",{query:t,page:e})},handleSelectionChange:function(e){this.$data.selectedUsers=e},closeResetPasswordDialog:function(){this.resetPasswordDialogOpen=!1,this.$store.dispatch("RemovePasswordToken")},showAdminAction:function(e){var t=e.local,s=e.id;return t&&this.showDeactivatedButton(s)},showDeactivatedButton:function(e){return this.$store.state.user.id!==e},toggleTag:function(e,t){e.tags.includes(t)?this.$store.dispatch("RemoveTag",{users:[e],tag:t}):this.$store.dispatch("AddTag",{users:[e],tag:t})},toggleUserRight:function(e,t){e.roles[t]?this.$store.dispatch("DeleteRight",{users:[e],right:t}):this.$store.dispatch("AddRight",{users:[e],right:t})},handleEmailConfirmation:function(e){this.$store.dispatch("ConfirmUsersEmail",[e])},handleConfirmationResend:function(e){this.$store.dispatch("ResendConfirmationEmail",[e])}}},C=(s("6eCR"),Object(h.a)(U,function(){var e=this,t=e.$createElement,s=e._self._c||t;return s("div",{staticClass:"users-container"},[s("h1",[e._v("\n    "+e._s(e.$t("users.users"))+"\n    "),s("span",{staticClass:"user-count"},[e._v("("+e._s(e.normalizedUsersCount)+")")])]),e._v(" "),s("div",{staticClass:"filter-container"},[s("users-filter"),e._v(" "),s("el-input",{staticClass:"search",attrs:{placeholder:e.$t("users.search")},on:{input:e.handleDebounceSearchInput},model:{value:e.search,callback:function(t){e.search=t},expression:"search"}})],1),e._v(" "),s("div",{staticClass:"actions-container"},[s("el-button",{staticClass:"actions-button create-account",on:{click:function(t){e.createAccountDialogOpen=!0}}},[s("span",[s("i",{staticClass:"el-icon-plus"}),e._v("\n        "+e._s(e.$t("users.createAccount"))+"\n      ")])]),e._v(" "),s("multiple-users-menu",{attrs:{"selected-users":e.selectedUsers},on:{"apply-action":e.clearSelection}})],1),e._v(" "),s("new-account-dialog",{attrs:{"dialog-form-visible":e.createAccountDialogOpen},on:{createNewAccount:e.createNewAccount,closeWindow:function(t){e.createAccountDialogOpen=!1}}}),e._v(" "),s("el-table",{directives:[{name:"loading",rawName:"v-loading",value:e.loading,expression:"loading"}],ref:"usersTable",staticStyle:{width:"100%"},attrs:{data:e.users,"row-key":"id"},on:{"selection-change":e.handleSelectionChange}},[e.isDesktop?s("el-table-column",{attrs:{type:"selection","reserve-selection":"",width:"44",align:"center"}}):e._e(),e._v(" "),s("el-table-column",{attrs:{"min-width":e.width,label:e.$t("users.id"),prop:"id"}}),e._v(" "),s("el-table-column",{attrs:{label:e.$t("users.name"),prop:"nickname"},scopedSlots:e._u([{key:"default",fn:function(t){return[s("router-link",{attrs:{to:{name:"UsersShow",params:{id:t.row.id}}}},[e._v(e._s(t.row.nickname))]),e._v(" "),e.isDesktop?s("el-tag",{attrs:{type:"info",size:"mini"}},[s("span",[e._v(e._s(t.row.local?e.$t("users.local"):e.$t("users.external")))])]):e._e()]}}])}),e._v(" "),s("el-table-column",{attrs:{"min-width":e.width,label:e.$t("users.status")},scopedSlots:e._u([{key:"default",fn:function(t){return[s("el-tag",{attrs:{type:t.row.deactivated?"danger":"success"}},[e.isDesktop?s("span",[e._v(e._s(t.row.deactivated?e.$t("users.deactivated"):e.$t("users.active")))]):s("i",{class:e.activationIcon(t.row.deactivated)})]),e._v(" "),t.row.roles.admin?s("el-tag",[s("span",[e._v(e._s(e.isDesktop?e.$t("users.admin"):e.getFirstLetter(e.$t("users.admin"))))])]):e._e(),e._v(" "),t.row.roles.moderator?s("el-tag",[s("span",[e._v(e._s(e.isDesktop?e.$t("users.moderator"):e.getFirstLetter(e.$t("users.moderator"))))])]):e._e(),e._v(" "),s("el-tooltip",{attrs:{content:e.$t("users.unconfirmedEmail"),effect:"dark"}},[t.row.confirmation_pending?s("el-tag",{attrs:{type:"info"}},[e._v("\n            "+e._s(e.isDesktop?e.$t("users.unconfirmed"):e.getFirstLetter(e.$t("users.unconfirmed")))+"\n          ")]):e._e()],1)]}}])}),e._v(" "),s("el-table-column",{attrs:{label:e.$t("users.actions"),fixed:"right"},scopedSlots:e._u([{key:"default",fn:function(t){return[s("el-dropdown",{attrs:{"hide-on-click":!1,size:"small",trigger:"click"}},[s("span",{staticClass:"el-dropdown-link"},[e._v("\n            "+e._s(e.$t("users.moderation"))+"\n            "),e.isDesktop?s("i",{staticClass:"el-icon-arrow-down el-icon--right"}):e._e()]),e._v(" "),s("el-dropdown-menu",{attrs:{slot:"dropdown"},slot:"dropdown"},[e.showAdminAction(t.row)?s("el-dropdown-item",{nativeOn:{click:function(s){return e.toggleUserRight(t.row,"admin")}}},[e._v("\n              "+e._s(t.row.roles.admin?e.$t("users.revokeAdmin"):e.$t("users.grantAdmin"))+"\n            ")]):e._e(),e._v(" "),e.showAdminAction(t.row)?s("el-dropdown-item",{nativeOn:{click:function(s){return e.toggleUserRight(t.row,"moderator")}}},[e._v("\n              "+e._s(t.row.roles.moderator?e.$t("users.revokeModerator"):e.$t("users.grantModerator"))+"\n            ")]):e._e(),e._v(" "),e.showDeactivatedButton(t.row.id)?s("el-dropdown-item",{attrs:{divided:e.showAdminAction(t.row)},nativeOn:{click:function(s){return e.toggleActivation(t.row)}}},[e._v("\n              "+e._s(t.row.deactivated?e.$t("users.activateAccount"):e.$t("users.deactivateAccount"))+"\n            ")]):e._e(),e._v(" "),e.showDeactivatedButton(t.row.id)?s("el-dropdown-item",{nativeOn:{click:function(s){return e.handleDeletion(t.row)}}},[e._v("\n              "+e._s(e.$t("users.deleteAccount"))+"\n            ")]):e._e(),e._v(" "),t.row.local&&t.row.confirmation_pending?s("el-dropdown-item",{attrs:{divided:""},nativeOn:{click:function(s){return e.handleEmailConfirmation(t.row)}}},[e._v("\n              "+e._s(e.$t("users.confirmAccount"))+"\n            ")]):e._e(),e._v(" "),t.row.local&&t.row.confirmation_pending?s("el-dropdown-item",{nativeOn:{click:function(s){return e.handleConfirmationResend(t.row)}}},[e._v("\n              "+e._s(e.$t("users.resendConfirmation"))+"\n            ")]):e._e(),e._v(" "),s("el-dropdown-item",{class:{"active-tag":t.row.tags.includes("force_nsfw")},attrs:{divided:e.showAdminAction(t.row)},nativeOn:{click:function(s){return e.toggleTag(t.row,"force_nsfw")}}},[e._v("\n              "+e._s(e.$t("users.forceNsfw"))+"\n              "),t.row.tags.includes("force_nsfw")?s("i",{staticClass:"el-icon-check"}):e._e()]),e._v(" "),s("el-dropdown-item",{class:{"active-tag":t.row.tags.includes("strip_media")},nativeOn:{click:function(s){return e.toggleTag(t.row,"strip_media")}}},[e._v("\n              "+e._s(e.$t("users.stripMedia"))+"\n              "),t.row.tags.includes("strip_media")?s("i",{staticClass:"el-icon-check"}):e._e()]),e._v(" "),s("el-dropdown-item",{class:{"active-tag":t.row.tags.includes("force_unlisted")},nativeOn:{click:function(s){return e.toggleTag(t.row,"force_unlisted")}}},[e._v("\n              "+e._s(e.$t("users.forceUnlisted"))+"\n              "),t.row.tags.includes("force_unlisted")?s("i",{staticClass:"el-icon-check"}):e._e()]),e._v(" "),s("el-dropdown-item",{class:{"active-tag":t.row.tags.includes("sandbox")},nativeOn:{click:function(s){return e.toggleTag(t.row,"sandbox")}}},[e._v("\n              "+e._s(e.$t("users.sandbox"))+"\n              "),t.row.tags.includes("sandbox")?s("i",{staticClass:"el-icon-check"}):e._e()]),e._v(" "),t.row.local?s("el-dropdown-item",{class:{"active-tag":t.row.tags.includes("disable_remote_subscription")},nativeOn:{click:function(s){return e.toggleTag(t.row,"disable_remote_subscription")}}},[e._v("\n              "+e._s(e.$t("users.disableRemoteSubscription"))+"\n              "),t.row.tags.includes("disable_remote_subscription")?s("i",{staticClass:"el-icon-check"}):e._e()]):e._e(),e._v(" "),t.row.local?s("el-dropdown-item",{class:{"active-tag":t.row.tags.includes("disable_any_subscription")},nativeOn:{click:function(s){return e.toggleTag(t.row,"disable_any_subscription")}}},[e._v("\n              "+e._s(e.$t("users.disableAnySubscription"))+"\n              "),t.row.tags.includes("disable_any_subscription")?s("i",{staticClass:"el-icon-check"}):e._e()]):e._e(),e._v(" "),t.row.local?s("el-dropdown-item",{attrs:{divided:""},nativeOn:{click:function(s){return e.getPasswordResetToken(t.row.nickname)}}},[e._v("\n              "+e._s(e.$t("users.getPasswordResetToken"))+"\n            ")]):e._e(),e._v(" "),t.row.local?s("el-dropdown-item",{nativeOn:{click:function(s){return e.requirePasswordReset(t.row.nickname)}}},[e._v("\n              "+e._s(e.$t("users.requirePasswordReset"))+"\n            ")]):e._e()],1)],1)]}}])})],1),e._v(" "),s("el-dialog",{directives:[{name:"loading",rawName:"v-loading",value:e.loading,expression:"loading"}],attrs:{visible:e.resetPasswordDialogOpen,title:e.$t("users.passwordResetTokenCreated"),"custom-class":"password-reset-token-dialog"},on:{"update:visible":function(t){e.resetPasswordDialogOpen=t},close:e.closeResetPasswordDialog}},[s("div",[s("p",{staticClass:"password-reset-token"},[e._v("Password reset token was generated: "+e._s(e.passwordResetToken))]),e._v(" "),s("p",[e._v("You can also use this link to reset password:\n        "),s("a",{staticClass:"reset-password-link",attrs:{href:e.passwordResetLink,target:"_blank"}},[e._v(e._s(e.passwordResetLink))])])])]),e._v(" "),e.loading?e._e():s("div",{staticClass:"pagination"},[s("el-pagination",{attrs:{total:e.usersCount,"current-page":e.currentPage,"page-size":e.pageSize,background:"",layout:"prev, pager, next"},on:{"current-change":e.handlePageChange}})],1)],1)},[],!1,null,null,null));C.options.__file="index.vue";t.default=C.exports},i7Kn:function(e,t,s){"use strict";var r=s("o0o1"),n=s.n(r),i=s("yXPU"),o=s.n(i),a={props:{selectedUsers:{type:Array,default:function(){return[]}}},computed:{showDropdownForMultipleUsers:function(){return this.$props.selectedUsers.length>0},isDesktop:function(){return"desktop"===this.$store.state.app.device}},methods:{mappers:function(){var e=this,t=function(){var t=o()(n.a.mark(function t(s,r){return n.a.wrap(function(t){for(;;)switch(t.prev=t.next){case 0:return t.next=2,r(s);case 2:e.$emit("apply-action");case 3:case"end":return t.stop()}},t)}));return function(e,s){return t.apply(this,arguments)}}();return{grantRight:function(s){return function(){var r=function(){var t=o()(n.a.mark(function t(r){return n.a.wrap(function(t){for(;;)switch(t.prev=t.next){case 0:return t.next=2,e.$store.dispatch("AddRight",{users:r,right:s});case 2:return t.abrupt("return",t.sent);case 3:case"end":return t.stop()}},t)}));return function(e){return t.apply(this,arguments)}}(),i=e.selectedUsers.filter(function(t){return t.local&&!t.roles[s]&&e.$store.state.user.id!==t.id});t(i,r)}},revokeRight:function(s){return function(){var r=function(){var t=o()(n.a.mark(function t(r){return n.a.wrap(function(t){for(;;)switch(t.prev=t.next){case 0:return t.next=2,e.$store.dispatch("DeleteRight",{users:r,right:s});case 2:return t.abrupt("return",t.sent);case 3:case"end":return t.stop()}},t)}));return function(e){return t.apply(this,arguments)}}(),i=e.selectedUsers.filter(function(t){return t.local&&t.roles[s]&&e.$store.state.user.id!==t.id});t(i,r)}},activate:function(){var s=e.selectedUsers.filter(function(t){return t.deactivated&&e.$store.state.user.id!==t.id});t(s,function(){var t=o()(n.a.mark(function t(s){return n.a.wrap(function(t){for(;;)switch(t.prev=t.next){case 0:return t.next=2,e.$store.dispatch("ActivateUsers",s);case 2:return t.abrupt("return",t.sent);case 3:case"end":return t.stop()}},t)}));return function(e){return t.apply(this,arguments)}}())},deactivate:function(){var s=e.selectedUsers.filter(function(t){return!t.deactivated&&e.$store.state.user.id!==t.id});t(s,function(){var t=o()(n.a.mark(function t(s){return n.a.wrap(function(t){for(;;)switch(t.prev=t.next){case 0:return t.next=2,e.$store.dispatch("DeactivateUsers",s);case 2:return t.abrupt("return",t.sent);case 3:case"end":return t.stop()}},t)}));return function(e){return t.apply(this,arguments)}}())},remove:function(){var s=e.selectedUsers.filter(function(t){return e.$store.state.user.id!==t.id});t(s,function(){var t=o()(n.a.mark(function t(s){return n.a.wrap(function(t){for(;;)switch(t.prev=t.next){case 0:return t.next=2,e.$store.dispatch("DeleteUsers",s);case 2:return t.abrupt("return",t.sent);case 3:case"end":return t.stop()}},t)}));return function(e){return t.apply(this,arguments)}}())},addTag:function(s){return function(){var r=e.selectedUsers.filter(function(e){return"disable_remote_subscription"===s||"disable_any_subscription"===s?e.local&&!e.tags.includes(s):!e.tags.includes(s)});t(r,function(){var t=o()(n.a.mark(function t(r){return n.a.wrap(function(t){for(;;)switch(t.prev=t.next){case 0:return t.next=2,e.$store.dispatch("AddTag",{users:r,tag:s});case 2:return t.abrupt("return",t.sent);case 3:case"end":return t.stop()}},t)}));return function(e){return t.apply(this,arguments)}}())}},removeTag:function(s){return o()(n.a.mark(function r(){var i;return n.a.wrap(function(r){for(;;)switch(r.prev=r.next){case 0:i=e.selectedUsers.filter(function(e){return"disable_remote_subscription"===s||"disable_any_subscription"===s?e.local&&e.tags.includes(s):e.tags.includes(s)}),t(i,function(){var t=o()(n.a.mark(function t(r){return n.a.wrap(function(t){for(;;)switch(t.prev=t.next){case 0:return t.next=2,e.$store.dispatch("RemoveTag",{users:r,tag:s});case 2:return t.abrupt("return",t.sent);case 3:case"end":return t.stop()}},t)}));return function(e){return t.apply(this,arguments)}}());case 3:case"end":return r.stop()}},r)}))},requirePasswordReset:function(){e.selectedUsers.filter(function(e){return e.local}).map(function(t){return e.$store.dispatch("RequirePasswordReset",t)}),e.$emit("apply-action")},confirmAccounts:function(){var s=e.selectedUsers.filter(function(e){return e.local&&e.confirmation_pending});t(s,function(){var t=o()(n.a.mark(function t(s){return n.a.wrap(function(t){for(;;)switch(t.prev=t.next){case 0:return t.next=2,e.$store.dispatch("ConfirmUsersEmail",s);case 2:return t.abrupt("return",t.sent);case 3:case"end":return t.stop()}},t)}));return function(e){return t.apply(this,arguments)}}())},resendConfirmation:function(){var s=e.selectedUsers.filter(function(e){return e.local&&e.confirmation_pending});t(s,function(){var t=o()(n.a.mark(function t(s){return n.a.wrap(function(t){for(;;)switch(t.prev=t.next){case 0:return t.next=2,e.$store.dispatch("ResendConfirmationEmail",s);case 2:return t.abrupt("return",t.sent);case 3:case"end":return t.stop()}},t)}));return function(e){return t.apply(this,arguments)}}())}}},grantRightToMultipleUsers:function(e){var t=this.mappers().grantRight;this.confirmMessage(this.$t("users.grantRightConfirmation",{right:e}),t(e))},revokeRightFromMultipleUsers:function(e){var t=this.mappers().revokeRight;this.confirmMessage(this.$t("users.revokeRightConfirmation",{right:e}),t(e))},activateMultipleUsers:function(){var e=this.mappers().activate;this.confirmMessage(this.$t("users.activateMultipleUsersConfirmation"),e)},deactivateMultipleUsers:function(){var e=this.mappers().deactivate;this.confirmMessage(this.$t("users.deactivateMultipleUsersConfirmation"),e)},deleteMultipleUsers:function(){var e=this.mappers().remove;this.confirmMessage(this.$t("users.deleteMultipleUsersConfirmation"),e)},requirePasswordReset:function(){if(this.$store.state.user.nodeInfo.metadata.mailerEnabled){var e=this.mappers().requirePasswordReset;this.confirmMessage(this.$t("users.requirePasswordResetConfirmation"),e)}else this.$alert(this.$t("users.mailerMustBeEnabled"),"Error",{type:"error"})},addTagForMultipleUsers:function(e){var t=this.mappers().addTag;this.confirmMessage(this.$t("users.addTagForMultipleUsersConfirmation"),t(e))},removeTagFromMultipleUsers:function(e){var t=this.mappers().removeTag;this.confirmMessage(this.$t("users.removeTagFromMultipleUsersConfirmation"),t(e))},confirmAccountsForMultipleUsers:function(){var e=this.mappers().confirmAccounts;this.confirmMessage(this.$t("users.confirmAccountsConfirmation"),e)},resendConfirmationForMultipleUsers:function(){var e=this.mappers().resendConfirmation;this.confirmMessage(this.$t("users.resendEmailConfirmation"),e)},confirmMessage:function(e,t){var s=this;this.$confirm(e,{confirmButtonText:this.$t("users.ok"),cancelButtonText:this.$t("users.cancel"),type:"warning"}).then(function(){t()}).catch(function(){s.$message({type:"info",message:s.$t("users.canceled")})})}}},c=(s("NQWY"),s("KHd+")),u=Object(c.a)(a,function(){var e=this,t=e.$createElement,s=e._self._c||t;return s("el-dropdown",{attrs:{size:"small",trigger:"click",placement:"bottom-start"}},[e.isDesktop?s("el-button",{staticClass:"actions-button"},[s("span",{staticClass:"actions-button-container"},[s("span",[s("i",{staticClass:"el-icon-edit"}),e._v("\n        "+e._s(e.$t("users.moderateUsers"))+"\n      ")]),e._v(" "),s("i",{staticClass:"el-icon-arrow-down el-icon--right"})])]):e._e(),e._v(" "),e.showDropdownForMultipleUsers?s("el-dropdown-menu",{attrs:{slot:"dropdown"},slot:"dropdown"},[s("el-dropdown-item",{nativeOn:{click:function(t){return e.grantRightToMultipleUsers("admin")}}},[e._v("\n      "+e._s(e.$t("users.grantAdmin"))+"\n    ")]),e._v(" "),s("el-dropdown-item",{nativeOn:{click:function(t){return e.revokeRightFromMultipleUsers("admin")}}},[e._v("\n      "+e._s(e.$t("users.revokeAdmin"))+"\n    ")]),e._v(" "),s("el-dropdown-item",{nativeOn:{click:function(t){return e.grantRightToMultipleUsers("moderator")}}},[e._v("\n      "+e._s(e.$t("users.grantModerator"))+"\n    ")]),e._v(" "),s("el-dropdown-item",{nativeOn:{click:function(t){return e.revokeRightFromMultipleUsers("moderator")}}},[e._v("\n      "+e._s(e.$t("users.revokeModerator"))+"\n    ")]),e._v(" "),s("el-dropdown-item",{attrs:{divided:""},nativeOn:{click:function(t){return e.confirmAccountsForMultipleUsers(t)}}},[e._v("\n      "+e._s(e.$t("users.confirmAccounts"))+"\n    ")]),e._v(" "),s("el-dropdown-item",{nativeOn:{click:function(t){return e.resendConfirmationForMultipleUsers(t)}}},[e._v("\n      "+e._s(e.$t("users.resendConfirmation"))+"\n    ")]),e._v(" "),s("el-dropdown-item",{attrs:{divided:""},nativeOn:{click:function(t){return e.activateMultipleUsers(t)}}},[e._v("\n      "+e._s(e.$t("users.activateAccounts"))+"\n    ")]),e._v(" "),s("el-dropdown-item",{nativeOn:{click:function(t){return e.deactivateMultipleUsers(t)}}},[e._v("\n      "+e._s(e.$t("users.deactivateAccounts"))+"\n    ")]),e._v(" "),s("el-dropdown-item",{nativeOn:{click:function(t){return e.deleteMultipleUsers(t)}}},[e._v("\n      "+e._s(e.$t("users.deleteAccounts"))+"\n    ")]),e._v(" "),s("el-dropdown-item",{nativeOn:{click:function(t){return e.requirePasswordReset(t)}}},[e._v("\n      "+e._s(e.$t("users.requirePasswordReset"))+"\n    ")]),e._v(" "),s("el-dropdown-item",{staticClass:"no-hover",attrs:{divided:""}},[s("div",{staticClass:"tag-container"},[s("span",{staticClass:"tag-text"},[e._v(e._s(e.$t("users.forceNsfw")))]),e._v(" "),s("el-button-group",{staticClass:"tag-button-group"},[s("el-button",{attrs:{size:"mini"},nativeOn:{click:function(t){return e.addTagForMultipleUsers("force_nsfw")}}},[e._v("\n            "+e._s(e.$t("users.apply"))+"\n          ")]),e._v(" "),s("el-button",{attrs:{size:"mini"},nativeOn:{click:function(t){return e.removeTagFromMultipleUsers("force_nsfw")}}},[e._v("\n            "+e._s(e.$t("users.remove"))+"\n          ")])],1)],1)]),e._v(" "),s("el-dropdown-item",{staticClass:"no-hover"},[s("div",{staticClass:"tag-container"},[s("span",{staticClass:"tag-text"},[e._v(e._s(e.$t("users.stripMedia")))]),e._v(" "),s("el-button-group",{staticClass:"tag-button-group"},[s("el-button",{attrs:{size:"mini"},nativeOn:{click:function(t){return e.addTagForMultipleUsers("strip_media")}}},[e._v("\n            "+e._s(e.$t("users.apply"))+"\n          ")]),e._v(" "),s("el-button",{attrs:{size:"mini"},nativeOn:{click:function(t){return e.removeTagFromMultipleUsers("strip_media")}}},[e._v("\n            "+e._s(e.$t("users.remove"))+"\n          ")])],1)],1)]),e._v(" "),s("el-dropdown-item",{staticClass:"no-hover"},[s("div",{staticClass:"tag-container"},[s("span",{staticClass:"tag-text"},[e._v(e._s(e.$t("users.forceUnlisted")))]),e._v(" "),s("el-button-group",{staticClass:"tag-button-group"},[s("el-button",{attrs:{size:"mini"},nativeOn:{click:function(t){return e.addTagForMultipleUsers("force_unlisted")}}},[e._v("\n            "+e._s(e.$t("users.apply"))+"\n          ")]),e._v(" "),s("el-button",{attrs:{size:"mini"},nativeOn:{click:function(t){return e.removeTagFromMultipleUsers("force_unlisted")}}},[e._v("\n            "+e._s(e.$t("users.remove"))+"\n          ")])],1)],1)]),e._v(" "),s("el-dropdown-item",{staticClass:"no-hover"},[s("div",{staticClass:"tag-container"},[s("span",{staticClass:"tag-text"},[e._v(e._s(e.$t("users.sandbox")))]),e._v(" "),s("el-button-group",{staticClass:"tag-button-group"},[s("el-button",{attrs:{size:"mini"},nativeOn:{click:function(t){return e.addTagForMultipleUsers("sandbox")}}},[e._v("\n            "+e._s(e.$t("users.apply"))+"\n          ")]),e._v(" "),s("el-button",{attrs:{size:"mini"},nativeOn:{click:function(t){return e.removeTagFromMultipleUsers("sandbox")}}},[e._v("\n            "+e._s(e.$t("users.remove"))+"\n          ")])],1)],1)]),e._v(" "),s("el-dropdown-item",{staticClass:"no-hover"},[s("div",{staticClass:"tag-container"},[s("span",{staticClass:"tag-text"},[e._v(e._s(e.$t("users.disableRemoteSubscriptionForMultiple")))]),e._v(" "),s("el-button-group",{staticClass:"tag-button-group"},[s("el-button",{attrs:{size:"mini"},nativeOn:{click:function(t){return e.addTagForMultipleUsers("disable_remote_subscription")}}},[e._v("\n            "+e._s(e.$t("users.apply"))+"\n          ")]),e._v(" "),s("el-button",{attrs:{size:"mini"},nativeOn:{click:function(t){return e.removeTagFromMultipleUsers("disable_remote_subscription")}}},[e._v("\n            "+e._s(e.$t("users.remove"))+"\n          ")])],1)],1)]),e._v(" "),s("el-dropdown-item",{staticClass:"no-hover"},[s("div",{staticClass:"tag-container"},[s("span",{staticClass:"tag-text"},[e._v(e._s(e.$t("users.disableAnySubscriptionForMultiple")))]),e._v(" "),s("el-button-group",{staticClass:"tag-button-group"},[s("el-button",{attrs:{size:"mini"},nativeOn:{click:function(t){return e.addTagForMultipleUsers("disable_any_subscription")}}},[e._v("\n            "+e._s(e.$t("users.apply"))+"\n          ")]),e._v(" "),s("el-button",{attrs:{size:"mini"},nativeOn:{click:function(t){return e.removeTagFromMultipleUsers("disable_any_subscription")}}},[e._v("\n            "+e._s(e.$t("users.remove"))+"\n          ")])],1)],1)])],1):s("el-dropdown-menu",{attrs:{slot:"dropdown"},slot:"dropdown"},[s("el-dropdown-item",[e._v("\n      "+e._s(e.$t("users.selectUsers"))+"\n    ")])],1)],1)},[],!1,null,"56aa3725",null);u.options.__file="MultipleUsersMenu.vue";t.a=u.exports},vg5t:function(e,t,s){}}]);
//# sourceMappingURL=chunk-f5e2.0e1ac30b.js.map