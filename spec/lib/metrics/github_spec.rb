require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../../../../app/models', __FILE__)
require File.expand_path('../../../../lib/metrics/github', __FILE__)

describe Metrics::Github do

  describe 'with a .git github URL' do
    before do
      @github = Metrics::Github.new
      @github.initialize_client('https://github.com/myusername/reponame.git')
    end
    it 'has the right user' do
      @github.user.should == 'myusername'
    end
    it 'has the right repo' do
      @github.repo.should == 'reponame'
    end
  end

  describe 'with a non .git github URL' do
    before do
      @github = Metrics::Github.new
      @github.initialize_client('https://github.com/myusername/reponame')
    end
    it 'has the right user' do
      @github.user.should == 'myusername'
    end
    it 'has the right repo' do
      @github.repo.should == 'reponame'
    end
  end

  describe 'with a private github URL' do
    before do
      @github = Metrics::Github.new
      @github.initialize_client('git@github.com/myusername/reponame.git')
    end
    it 'has the right user' do
      @github.user.should == 'myusername'
    end
    it 'has the right repo' do
      @github.repo.should == 'reponame'
    end
  end

  describe 'with a ? github URL' do
    before do
      @github = Metrics::Github.new
      @github.initialize_client('git://github.com/myusername/reponame.git')
    end
    it 'has the right user' do
      @github.user.should == 'myusername'
    end
    it 'has the right repo' do
      @github.repo.should == 'reponame'
    end
  end

  describe 'with an error case' do
    before do
      @github = Metrics::Github.new
      @github.initialize_client('https://github.com/RestKit/RestKit.git')
    end
    it 'has the right user' do
      @github.user.should == 'RestKit'
    end
    it 'has the right repo' do
      @github.repo.should == 'RestKit'
    end
  end

  describe 'not_found' do
    before do
      @github = Metrics::Github.new
      @github.initialize_client('https://github.com/myusername/reponame.git')
    end
    it 'updates not found on existing github metrics' do
      pod = Pod.create(:name => 'PodHasMetrics')
      metrics = GithubPodMetrics.create(:pod_id => pod.id, :not_found => 2)

      @github.not_found(pod)

      metrics.reload.not_found.should == 3
    end
    it 'creates metrics with not found' do
      pod = Pod.create(:name => 'PodNoMetrics')
      pod.github_pod_metrics.nil?.should == true

      @github.not_found(pod)

      pod.reload.github_pod_metrics.not_found.should == 1
    end
  end

  describe 'reset_not_found' do
    before do
      @github = Metrics::Github.new
    end
    it 'resets not found on existing github metrics' do
      pod = Pod.create(:name => 'PodHasMetrics')
      metrics = GithubPodMetrics.create(:pod_id => pod.id, :not_found => 2)

      @github.reset_not_found(pod)

      metrics.reload.not_found.should == 0
    end
    it 'ignores metrics with no not found' do
      pod = Pod.create(:name => 'PodNoMetrics')
      pod.github_pod_metrics.nil?.should == true

      @github.reset_not_found(pod)

      pod.github_pod_metrics.nil?.should == true
    end
  end

end
