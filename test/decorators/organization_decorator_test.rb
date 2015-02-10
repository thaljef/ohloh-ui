require 'test_helper'

class OrganizationDecoratorTest < ActiveSupport::TestCase
  let(:linux) { create(:organization, url_name: 'linux') }
  let(:sidebar) do
    [
      [
        [:org_summary, 'Organization Summary', '/orgs/linux'],
        [:settings, 'Settings', '/orgs/linux/settings'],
        [:widgets, 'Widgets', '/orgs/linux/widgets']
      ],
      [
        [:code_data, 'Project Portfolio'],
        [:projects, 'Claimed Projects', '/orgs/linux/projects']
      ]
    ]
  end

  it 'should return array of sidebar menus' do
    linux.decorate.sidebar.must_equal sidebar
  end
end
