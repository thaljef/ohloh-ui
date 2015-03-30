class Contribution < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :position
  belongs_to :project
  belongs_to :person
  belongs_to :name_fact
  belongs_to :contributor_fact, foreign_key: 'name_fact_id'
  has_many :invites
  has_many :kudos, ->(contribution) { joins(:name_fact).where(name_fact: { id: contribution.name_fact_id }) },
           primary_key: :project_id, foreign_key: :project_id

  scope :sort_by_name, -> { order('LOWER(people.effective_name)') }
  scope :sort_by_kudo_position, -> { order('people.kudo_position NULLS LAST') }
  scope :sort_by_commits, -> { order('name_facts.commits DESC NULLS LAST') }
  scope :sort_by_twelve_month_commits, -> { order('name_facts.twelve_month_commits DESC NULLS LAST') }
  scope :sort_by_language, -> { order('lower(languages.nice_name) NULLS LAST, name_facts.commits DESC NULLS LAST') }
  scope :sort_by_latest_commit, -> { order('name_facts.last_checkin DESC NULLS LAST') }
  scope :sort_by_newest, -> { order('name_facts.first_checkin DESC NULLS LAST') }
  scope :sort_by_oldest, -> { order('name_facts.first_checkin NULLS FIRST') }

  scope :filter_by, lambda { |query|
    includes(person: :account, contributor_fact: :primary_language)
      .references(:all)
      .where('effective_name ilike :query or accounts.akas ilike :query or languages.nice_name ilike :query ' \
             'or languages.name ilike :query', query: "%#{query}%") if query
  }

  def recent_kudos(limit = 3)
    kudos.limit(limit)
  end

  def analysis_aliases
    AnalysisAlias.for_contribution(self)
  end

  def scm_names
    analysis_aliases.collect(&:commit_name).uniq.compact
  end

  def committer_name
    name_fact_id ? contributor_fact.name.name : person.effective_name
  end

  class << self
    def generate_id_from_project_id_and_name_id(project_id, name_id)
      ((project_id << 32) + name_id + 0x80000000)
    end

    def generate_id_from_project_id_and_account_id(project_id, account_id)
      (project_id << 32) + account_id
    end

    def generate_project_id_and_name_id_from_id(id)
      [id >> 32, id & 0x7FFFFFFF]
    end

    def find_contribution_indirectly(id:, project:)
      aka = find_alias_from_name_id(id, project)
      return unless aka
      find_from_generated_id(project, aka) || find_from_positions(project, aka)
    end

    private

    def find_alias_from_name_id(id, project)
      _, name_id = generate_project_id_and_name_id_from_id(id.to_i)
      project.aliases.where(commit_name_id: name_id).first
    end

    def find_from_generated_id(project, aka)
      id = generate_id_from_project_id_and_name_id(project.id, aka.preferred_name_id)
      project.contributions.where(id: id).first
    end

    def find_from_positions(project, aka)
      position = project.positions.where(name_id: aka.preferred_name_id).first
      return unless position
      id = generate_id_from_project_id_and_account_id(project.id, position.account_id)
      project.contributions.where(id: id).first
    end
  end
end
