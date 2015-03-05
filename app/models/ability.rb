# -*- encoding : utf-8 -*-
class Ability
  include CanCan::Ability

  def initialize(user)

    orgs={1 => 100, 2 => 100, 3 => 100, 4 => 100, 5 => 100, 6 => 1, 7 => 2, 8 => 3, 9 => 4, 10 => 5, 11 => 6, 12 => 7, 13 => 8, 14 => 9, 15 => 10, 16 => 11, 17 => 12, 18 => 13, 19 => 14}
    can :read, :all
    user = user['info']['person']
    user['roles'].each do |role|
      if (role['name'] == "President" || role['name'] == "Vicepresident") && role['organization']['name']=="Krajské předsednictvo"
        # Členové krajského předsednictva
        can [:manage], [Donation,Invoice,BudgetCategory], organization_id: orgs[role['organization']['id']]
      elsif role['organization'].try(:'id')=="1"
        # Členové republikového předsednictva
        can [:manage], [Donation,Invoice,BudgetCategory], organization_id: 100
      end
    end

    if [42, 342, 344, 4039, 2804].member?(user['id'])
      can :manage, :all
    end

  end
end
