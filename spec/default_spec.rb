require 'spec_helper'

describe 'chef-zero::default' do
  platforms = {
    'ubuntu' => ['12.04', '14.04'],
    'centos' => ['6.5', '7.0'],
  }

  platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::ServerRunner.new(platform: platform, version: version) do |node|
            node.override['chef-zero'] = {
              'install' => true,
              'start'   => true,
            }
          end.converge('chef-zero::default')
        end

        it 'uses the build-essential recipe' do
          expect(chef_run).to include_recipe('build-essential::default')
        end

        it 'installs the chef-zero gem' do
          expect(chef_run).to install_chef_gem('chef-zero').with(version: '1.5.1')
        end

        it 'drops the /etc/init.d script with correct permissions' do
          expect(chef_run).to create_template('/etc/init.d/chef-zero').with(
            user: 'root',
            group: 'root',
            mode: '0755'
          )
        end

        it 'starts the service' do
          expect(chef_run).to start_service('chef-zero')
        end

        it 'enables the service' do
          expect(chef_run).to enable_service('chef-zero')
        end
      end
    end
  end
end
