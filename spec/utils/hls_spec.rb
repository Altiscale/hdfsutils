require_relative '../spec_helper'
require 'utils/hls/ls'

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

    dirname = '/user/testuser/testdir'

    stub_request(:get, "http://nn-cluster.nsdc.altiscale.com:50070/webhdfs/v1/?op=GETFILESTATUS&user.name=testuser").to_return(:body => JSON.generate(test_dir_stat_001))

    stub_request(:get, "http://nn-cluster.nsdc.altiscale.com:50070/webhdfs/v1#{dirname}?op=GETFILESTATUS&user.name=testuser").to_return(:body => '{"FileStatus":{"accessTime":0,"blockSize":0,"childrenNum":2,"fileId":16580,"group":"users","length":0,"modificationTime":1431723784561,"owner":"testuser","pathSuffix":"","permission":"755","replication":0,"type":"DIRECTORY"}}', :headers => {"Content-Type" => "application/json"})

    ENV['HDFS_HOST'] = 'nn-cluster.nsdc.altiscale.com'
    ENV['HDFS_PORT'] = '50070'
    ENV['HDFS_USERNAME'] = 'testuser'

    ls_output = 'drwxr-xr-x   - testuser users ' +
                '         0 2015-05-15 21:03 ' +
                dirname + "\n"

    expect { HdfsUtils::Ls.new(['--log-level', 'dEbUg', dirname]).run }
      .to output(ls_output)
      .to_stdout
  end
end

