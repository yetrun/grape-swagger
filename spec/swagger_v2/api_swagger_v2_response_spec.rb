# frozen_string_literal: true

require 'spec_helper'

describe 'response' do
  include_context "#{MODEL_PARSER} swagger example"

  let(:api) { Class.new(Grape::API) }

  before(:each) do
    api.format :json
  end

  def app
    api
  end

  subject do
    api.add_swagger_documentation

    get '/swagger_doc'
    JSON.parse(last_response.body)
  end

  describe 'uses nested type as response object' do
    before do
      api.desc 'This returns something',
               entity: Entities::UseItemResponseAsType,
               failure: [{ code: 400, message: 'NotFound', model: Entities::ApiError }]
      api.get do
        { 'declared_params' => declared(params) }
      end
    end

    specify do
      expect(subject['paths']['/']['get']).to eql(
        'summary' => 'This returns something',
        'description' => 'This returns something',
        'produces' => ['application/json'],
        'responses' => {
          '200' => { 'description' => 'This returns something', 'schema' => { '$ref' => '#/definitions/UseItemResponseAsType' } },
          '400' => { 'description' => 'NotFound', 'schema' => { '$ref' => '#/definitions/ApiError' } }
        },
        'operationId' => 'get'
      )
      expect(subject['definitions']).to eql(swagger_nested_type)
    end
  end

  describe 'uses entity as response object' do
    before do
      api.desc 'This returns something',
               entity: Entities::UseResponse,
               failure: [{ code: 400, message: 'NotFound', model: Entities::ApiError }]
      api.get do
        { 'declared_params' => declared(params) }
      end
    end

    specify do
      expect(subject['paths']['/']['get']).to eql(
        'summary' => 'This returns something',
        'description' => 'This returns something',
        'produces' => ['application/json'],
        'responses' => {
          '200' => { 'description' => 'This returns something', 'schema' => { '$ref' => '#/definitions/UseResponse' } },
          '400' => { 'description' => 'NotFound', 'schema' => { '$ref' => '#/definitions/ApiError' } }
        },
        'operationId' => 'get'
      )
      expect(subject['definitions']).to eql(swagger_entity_as_response_object)
    end
  end

  describe 'uses status DSL as response object' do
    before do
      api.desc 'This returns something'
      api.status 200, Entities::UseResponse
      api.status 400, 'NotFound', Entities::ApiError
      api.get do
        { 'declared_params' => declared(params) }
      end
    end

    specify do
      expect(subject['paths']['/']['get']).to eql(
        'summary' => 'This returns something',
        'description' => 'This returns something',
        'produces' => ['application/json'],
        'responses' => {
          '200' => { 'description' => '', 'schema' => { '$ref' => '#/definitions/UseResponse' } },
          '400' => { 'description' => 'NotFound', 'schema' => { '$ref' => '#/definitions/ApiError' } }
        },
        'operationId' => 'get'
      )
      expect(subject['definitions']).to eql(swagger_entity_as_response_object)
    end
  end

  describe 'uses params as response object' do
    before do
      api.desc 'This returns something',
               params: Entities::UseResponse.documentation,
               failure: [{ code: 400, message: 'NotFound', model: Entities::ApiError }]
      api.post do
        { 'declared_params' => declared(params) }
      end
    end

    specify do
      expect(subject['paths']['/']['post']).to eql(
        'summary' => 'This returns something',
        'description' => 'This returns something',
        'produces' => ['application/json'],
        'consumes' => ['application/json'],
        'parameters' => [
          { 'in' => 'formData', 'name' => 'description', 'type' => 'string', 'required' => false },
          { 'in' => 'formData', 'name' => '$responses', 'type' => 'array', 'items' => { 'type' => 'string' }, 'required' => false }
        ],
        'responses' => {
          '201' => { 'description' => 'This returns something' },
          '400' => { 'description' => 'NotFound', 'schema' => { '$ref' => '#/definitions/ApiError' } }
        },
        'operationId' => 'post'
      )
      expect(subject['definitions']).to eql(swagger_params_as_response_object)
    end
  end

  describe 'uses params as response object when response contains multiple values for success' do
    before do
      api.desc 'This returns something',
               success: [
                 { code: 200, message: 'Request has succeeded' },
                 { code: 201, message: 'Successful Operation' },
                 { code: 204, message: 'Request was fulfilled' }
               ],
               failure: [{ code: 400, message: 'NotFound', model: Entities::ApiError }]
      api.get do
        { 'declared_params' => declared(params) }
      end
    end

    specify do
      expect(subject['paths']['/']['get']).to eql(
        'summary' => 'This returns something',
        'description' => 'This returns something',
        'produces' => ['application/json'],
        'responses' => {
          '200' => { 'description' => 'Request has succeeded' },
          '201' => { 'description' => 'Successful Operation' },
          '204' => { 'description' => 'Request was fulfilled' },
          '400' => { 'description' => 'NotFound', 'schema' => { '$ref' => '#/definitions/ApiError' } }
        },
        'operationId' => 'get'
      )
      expect(subject['definitions']).to eql(swagger_params_as_response_object)
    end
  end
end
