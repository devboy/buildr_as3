class Jeweler
  require File.dirname(__FILE__)+'/pre_release_to_git'
  require File.dirname(__FILE__)+'/pre_release_gemspec'

  def prerelease_to_git
    Jeweler::Commands::PreReleaseToGit.build_for(self).run
  end

  def prerelease_gemspec
    Jeweler::Commands::PreReleaseGemspec.build_for(self).run
  end

  def is_prerelease_version?
    version.end_with? ".pre"
  end

end