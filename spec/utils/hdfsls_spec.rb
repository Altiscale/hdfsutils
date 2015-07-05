require_relative '../spec_helper'
require 'utils/hdfsls/ls'

describe HdfsUtils::Ls do
  it 'should ls a directory' do
    test_dir_stat_001 = {
      "FileStatus" => {
        "accessTime" => 0,
        "blockSize" => 0,
        "childrenNum" => 10,
        "fileId" => 16386,
        "group" => "hdfs",
        "length" => 0,
        "modificationTime" => 1433791576835,
        "owner" => "hdfs",
        "pathSuffix" => "",
        "permission" => "755",
        "replication" => 0,
        "type" => "DIRECTORY"
      }
    }

    stub_request(:get, "http://nn-kampala.test.altiscale.com:50070/webhdfs/v1/?op=GETFILESTATUS&user.name=chaiken").to_return(:body => JSON.generate(test_dir_stat_001))

    stub_request(:get, "http://nn-kampala.test.altiscale.com:50070/webhdfs/v1/user/testuser/testdir/?op=GETFILESTATUS&user.name=chaiken").to_return(:body => '{"FileStatus":{"accessTime":0,"blockSize":0,"childrenNum":2,"fileId":16580,"group":"users","length":0,"modificationTime":1431723784561,"owner":"chaiken","pathSuffix":"","permission":"755","replication":0,"type":"DIRECTORY"}}', :headers => {"Content-Type" => "application/json"})

    expect { HdfsUtils::Ls.new(['/user/testuser/testdir/']).run }.to output("test output").to_stdout
  end
end

