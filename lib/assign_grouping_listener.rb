class AssignGroupingListener < Redmine::Hook::ViewListener
  def view_issues_form_details_bottom(context)
    groups = {}

    no_group_label = '----'
    add_entry_to_groups(groups, no_group_label, User.current.id, "<< #{l(:label_me)} >>")

    context[:issue].assignable_users.each do |user|
      if user.instance_of? Group
        add_entry_to_groups(groups, h(l(:label_group_plural)), user.id, user.name)
      else
        if user.groups.empty?
          add_entry_to_groups(groups, no_group_label, user.id, user.name)
        end
        user.groups.each do |user_group|
          add_entry_to_groups(groups, user_group.name, user.id, user.name)
        end
      end
    end

    context[:controller].send(
      :render_to_string,
      { :partial => 'hooks/assign_grouping',
        :layout  => false, 
        :locals => { :groups => groups } }
    )
  end

  private

  def add_entry_to_groups(groups, group_name, entry_id, entry_name)
    unless groups.has_key? group_name
      groups[group_name] = []
    end
    groups[group_name] << { id: entry_id, name: entry_name }
  end
end
