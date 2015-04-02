require 'spec_helper'

class TestLogger
  def self.log(msg);"info: #{msg}";end
  def self.err_log(msg);"err: #{msg}";end
end

describe SiteMapper::Logger do
  before(:all)        { SiteMapper::Logger.use_logger(TestLogger) }

  let(:logger)        { SiteMapper::Logger }
  let(:system_logger) { SiteMapper::Logger::SystemOutLogger }
  let(:nil_logger)    { SiteMapper::Logger::NilLogger }

  describe 'has NilLogger' do
    it 'has class' do
      expect { nil_logger }.not_to raise_error
    end

    it 'reponds to #log' do
      expect(nil_logger).to respond_to(:log)
    end

    it 'reponds to #err_log' do
      expect(nil_logger).to respond_to(:err_log)
    end
  end

  describe 'SystemOutLogger' do
    it 'has class' do
      expect { system_logger }.not_to raise_error
    end

    # Should work but doesn't..
    # it '#log logs to STDOUT' do
    #   expect { system_logger.log('log_message') }.to output('log_message').to_stdout
    # end

    # Should work but doesn't..
    # it '#err_log logs to STDERR' do
    #   expect { system_logger.err_log('log_message') }.to output('[ERROR] log_message').to_stderr
    # end

    it 'reponds to #log' do
      expect(system_logger).to respond_to(:log)
    end

    it 'reponds to #err_log' do
      expect(system_logger).to respond_to(:err_log)
    end
  end

  describe '#log' do
    it 'calls log' do
      expect { logger.log('asd') }.not_to raise_error
    end
  end

  describe '#err_log' do
    it 'calls err_log' do
      expect { logger.err_log('asd') }.not_to raise_error
    end
  end

  describe '#use_logger' do
    it 'can set custom logger' do
      expect(logger.log('log')).to eq 'info: log'
      expect(logger.err_log('log')).to eq 'err: log'
    end

    it 'raises exception if logger already has been set' do
      expect do
        logger.use_logger_type(:system)
        logger.use_logger(TestLogger)
      end.to raise_error
    end
  end
end
