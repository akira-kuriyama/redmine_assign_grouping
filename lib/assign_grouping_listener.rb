class AssignGroupingListener < Redmine::Hook::ViewListener
  def view_issues_form_details_bottom(context)
	issue = context[:issue]
	assignable_users = issue.assignable_users
	group_ids = (assignable_users.map {|user| user.groups.map {|group| group.id}}).flatten.uniq
	assignable_groups = Group.find(group_ids)

	groups = [] 
	assignable_groups.each do |group| 
		users = []
		assignable_users.each do |user| 
			user.groups.each do |ugroup|
				if ugroup.id == group.id
					users << {'name' => user.name, 'id' => user.id}
				end
			end
		end
		groups << {'lastname' => group.lastname, 'users' => users }
	end
	assignable_users.each do |user| 
		is_belong = false
		groups.each do |group| 
			group['users'].each do |guser|
				if guser['id'] == user.id 
					is_belong = true
				end
			end
		end
		if !is_belong
			independent_group = groups.find {|g| g['lastname'] == '----'} 
			if !independent_group 
				independent_group = {'lastname' => '----', 'users' => []}
				groups.unshift(independent_group)
			end
			independent_group['users'] << {'name' => user.name, 'id' => user.id}
		end
		if User.current.id == user.id 
			independent_group = groups.find {|g| g['lastname'] == '----'} 
			if !independent_group 
				independent_group = {'lastname' => '----', 'users' => []}
				groups.unshift(independent_group)
			end
			independent_group['users'].unshift({'name' => "<< #{l(:label_me)} >>", 'id' => user.id})

		end
	end
	
	#Rails.logger.info(groups)

	context[:controller].send(
       		:render_to_string,
		{
		  :partial => 'hooks/assign_grouping',
		  :layout  => false, 
		  :locals => { :groups => groups }
		}
      )
  end
end

