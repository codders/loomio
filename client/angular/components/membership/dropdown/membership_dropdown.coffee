Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
FlashService   = require 'shared/services/flash_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'
I18n           = require 'shared/services/i18n.coffee'

angular.module('loomioApp').directive 'membershipDropdown', ->
  scope: {membership: '='}
  restrict: 'E'
  templateUrl: 'generated/components/membership/dropdown/membership_dropdown.html'
  controller: ['$scope', ($scope) ->
    $scope.canPerformAction = ->
      $scope.canRemoveMembership() or
      $scope.canToggleAdmin()

    $scope.canRemoveMembership = ->
      AbilityService.canRemoveMembership($scope.membership)

    $scope.removeMembership = ->
      namespace = if $scope.membership.acceptedAt then 'membership' else 'invitation'
      ModalService.open 'ConfirmModal', confirm: ->
        scope:
          namespace: namespace
          user: $scope.membership.user()
        text:
          title:    "membership_remove_modal.#{namespace}.title"
          fragment: "membership_remove_modal"
          flash:    "membership_remove_modal.#{namespace}.flash"
          submit:   "membership_remove_modal.#{namespace}.submit"
        submit:     $scope.membership.destroy
        redirect:   ('dashboard' if $scope.membership.user() == Session.user())

    $scope.canToggleAdmin = ->
      AbilityService.canAdministerGroup($scope.membership.group()) and
      (!$scope.membership.admin or $scope.canRemoveMembership($scope.membership))

    $scope.toggleAdmin = (membership) ->
      method = if $scope.membership.admin then 'removeAdmin' else 'makeAdmin'
      return if $scope.membership.admin and $scope.membership.user() == Session.user() and !confirm(I18n.t('memberships_page.remove_admin_from_self.question'))
      Records.memberships[method]($scope.membership).then ->
        FlashService.success "memberships_page.messages.#{_.snakeCase method}_success", name: ($scope.membership.userName() || $scope.membership.userEmail())
  ]
