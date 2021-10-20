# frozen_string_literal: true

require 'spec_helper'

describe 'global configuration stuff' do
  include_context "#{MODEL_PARSER} swagger example"

  let(:api) { Class.new(Grape::API) }

  def app
    api
  end

  describe 'shows documentation paths' do
    before do
      api.format :json
      api.version 'v3', using: :path

      api.desc 'This returns something',
               failure: [{ code: 400, message: 'NotFound' }]
      api.params do
        requires :foo, type: Integer
      end
      api.get :configuration do
        { 'declared_params' => declared(params) }
      end

      api.add_swagger_documentation format: :json,
                                    doc_version: '23',
                                    schemes: 'https',
                                    host: -> { 'another.host.com' },
                                    base_path: -> { 'somewhere/over/the/rainbow' },
                                    mount_path: 'documentation',
                                    add_base_path: true,
                                    add_version: true,
                                    security_definitions: { api_key: { foo: 'bar' } },
                                    security: [{ api_key: [] }]
    end

    subject do
      get '/v3/documentation'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['info']['version']).to eql '23'
      expect(subject['host']).to eql 'another.host.com'
      expect(subject['basePath']).to eql 'somewhere/over/the/rainbow'
      expect(subject['paths'].keys.first).to eql '/somewhere/over/the/rainbow/v3/configuration'
      expect(subject['schemes']).to eql ['https']
      expect(subject['securityDefinitions'].keys).to include('api_key')
      expect(subject['securityDefinitions']['api_key']).to include('foo' => 'bar')
      expect(subject['security']).to include('api_key' => [])
    end
  end

  describe '实体定义中展开匿名类和参数实体' do
    let(:api) { Class.new(Grape::API) }

    before do
      api.format :json
      api.params do
        optional :name, type: String, documentation: { desc: 'name', in: 'body' }
        optional :mobile, type: String, documentation: { desc: 'mobile', in: 'body' }
      end
      api.status 200 do
        expose :count
        expose :use_response, using: Entities::UseResponse
      end
      api.post '/foo' do
        { declared_params: declared_params }
      end

      api.add_swagger_documentation expand_odd_references: true
    end

    def app
      api
    end

    subject do
      get '/swagger_doc'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['paths']['/foo']['post']['parameters']).to match [
        a_hash_including(
          'schema' => a_hash_including('type' => 'object')
        )
      ]

      expect(subject['paths']['/foo']['post']['responses']).to match a_hash_including(
        '200' => a_hash_including(
          'schema' => a_hash_including(
            'type' => 'object',
            'properties' => {
              'count' => { 'type' => 'string' },
              'use_response' => { '$ref' => '#/definitions/UseResponse' }
            }
          )
        )
      )

      expect(subject['definitions'].keys).to eq ['UseResponse']
    end
  end
end
