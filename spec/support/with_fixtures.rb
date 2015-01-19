module WithFixtures
  def fixture_path(*args)
    File.join(File.expand_path('../../fixtures', __FILE__), *args)
  end

  def fixture_content(*args)
    File.read(fixture_path(*args))
  end
end
