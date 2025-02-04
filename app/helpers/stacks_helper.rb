module StacksHelper
  def stack_edit_in_place
    haml_tag :a, class: 'rest_in_place_helper' do
      concat I18n.t('stacks.edit_in_place')
    end
  end

  def stack_similar_project_list(projects)
    # rubocop:disable Rails/OutputSafety # The values used here are sanitized.
    projects.collect do |proj|
      link_to(html_escape(proj.name), project_path(proj), title: html_escape(proj.name))
    end.join(', ').html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def stack_country_flag(code)
    return '' unless code && code.size == 2

    haml_tag 'img', src: "/assets/flags/#{code.downcase}.gif"
  end
end
