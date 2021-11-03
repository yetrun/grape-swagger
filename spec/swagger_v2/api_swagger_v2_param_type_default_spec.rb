# frozen_string_literal: true

require 'spec_helper'

describe '参数类型的默认值' do
  let(:api) do
    Class.new(Grape::API)
  end

  subject do
    api.add_swagger_documentation default_param_type: 'body'

    get '/swagger_doc'
    JSON.parse(last_response.body)
  end

  def app
    api
  end

  context 'GET 请求的默认值' do
    before do
      api.desc 'get in query params'
      api.params do
        optional :in_path, type: String
        optional :in_query, type: String
      end
      api.get '/in_query/:in_path'
    end

    specify do
      expect(subject['paths']['/in_query/{in_path}']['get']['parameters']).to match(
        a_collection_containing_exactly(
          a_hash_including('in' => 'path', 'name' => 'in_path'),
          a_hash_including('in' => 'query', 'name' => 'in_query')
        )
      )
    end
  end

  context 'POST 请求的默认值' do
    before do
      api.desc 'post in body params'
      api.params do
        requires :in_body_1, type: Integer, documentation: { desc: 'in_body_1' }
        optional :in_body_2, type: String, documentation: { desc: 'in_body_2' }
        optional :in_body_3, type: String, documentation: { desc: 'in_body_3' }
      end
      api.post '/in_body'
    end

    specify do
      expect(subject['paths']['/in_body']['post']['parameters']).to match(
        a_collection_containing_exactly(
          a_hash_including(
            'in' => 'body',
            'schema' => an_instance_of(Hash)
          )
        )
      )
    end
  end
end
