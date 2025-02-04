class ProjectExperience < ActiveRecord::Base
  belongs_to :position
  belongs_to :project
  belongs_to :project_with_experience, class_name: 'Project'
  attr_accessor :form_id

  validate :project_existence

  def project_name=(name)
    @project_name = name
    self.project = Project.not_deleted.case_insensitive_name(name).first
  end

  def project_name
    project.try(:name) || @project_name
  end

  private

  def project_existence
    return unless project_id.nil? && @project_name.present?

    errors.add(:project, I18n.t('project_experiences.no_matching_project'))
  end
end
