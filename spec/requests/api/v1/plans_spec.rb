require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Plan API", type: :request do
  let!(:user)               { FactoryBot.create(:user) }
  let!(:Authorization)      { "Bearer #{AuthTokenService.encode(user.id)}" }
  let!(:valid_header)       { { "Authorization": "Bearer #{AuthTokenService.encode(user.id)}" } }

  describe '/plans' do    
    path '/api/v1/plans' do
      get 'Returns all plans' do
        tags 'Plans'
        security [ bearer_auth: [] ]
        consumes 'application/json'
        produces 'application/json'
      
        response '200', 'index for plan model' do
          schema type: :array,
          properties: [
            type: :object,
            properties: {
              name: { type: :string, default: 'Plan99' },
              user_id: { type: :integer, default: 1 }
            },
            required: [ 'name', 'user_id' ] 
          ],
          example:[
            {
              name: 'Plan99',
              user_id: 1
            }
          ]

          run_test!
        end

        response '401', 'when user is unauthorized' do
          let!(:Authorization)  { nil }
          run_test!
        end
      end

      post 'Returns a plan' do
        tags 'Plans'
        security [ bearer_auth: [] ]
        consumes 'application/json'
        produces 'application/json'
        parameter name: :plans_data, in: :body, schema: {
          type: :object,
          properties: {
            plan: { 
              type: :object, 
              properties: {
                name: { type: :string, default: 'Plan99' },
                user_id: { type: :integer, default: 1 }
              },
              required: [ 'name', 'user_id' ]
            }
          }
        }
        
        response '201', 'plan created successfuly' do
          schema type: :object,
          properties: {
            plan: { 
              type: :object, 
              properties: {
                name: { type: :string, default: 'Plan99' },
                user_id: { type: :integer, default: 1 }
              },
              required: [ 'name', 'user_id' ]
            }
          }
          
          let(:plans_data)  { { plan: FactoryBot.attributes_for(:plan, user_id: user.id) } }
          
          it "with valid parameters creates a new Plan" do
            expect {
              post api_v1_plans_url,
                    params: plans_data, headers: valid_header, as: :json
            }.to change(Plan, :count).by(1)
          end
    
          it "with valid parameters renders a JSON response with the new plan" do
            post api_v1_plans_url,
                  params: plans_data, headers: valid_header, as: :json
            expect(response).to have_http_status(:created)
            expect(response.content_type).to match(a_string_including("application/json"))
          end
    
          
          run_test!
        end
        
        response '422', "plan couldn't be created" do
          schema type: :object,
          properties: {
            errors: {
              type: :object,
              properties: {
                name: {
                  type: :array, 
                  properties: [
                    { type: :string, default: "can't be blank" }
                  ]
                },
                user_id: {
                  type: :array, 
                  properties: [
                    { type: :string, default: "can't be nil" }
                  ]
                },
              }
            }
          },
          required: [ 'errors' ],
          example: {
            errors: 
            {
              name: [ "can't be blank" ],
              user_id: [ "can't be nil" ]
            }
          }
          
          let(:plans_data)  { { plan: { name: '', user_id: nil } } }

          it "with invalid parameters does not create a new Plan" do
            expect {
              post api_v1_plans_url,
                    params: plans_data, headers: valid_header, as: :json
            }.to change(Plan, :count).by(0)
          end
    
          it "with invalid parameters renders a JSON response with errors for the new plan" do
            post api_v1_plans_url,
                  params: { plan: plans_data }, headers: valid_header, as: :json
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.content_type).to match(a_string_including("application/json"))
          end

          run_test!
        end

        response '401', 'when user is unauthorized' do
          let(:plans_data)  { { plan: { name: '', user_id: nil } } }
          let(:Authorization) { nil }
          run_test!
        end
      end
    end
  end
end

#
#  describe "PATCH /update" do
#    context "with valid parameters" do
#      let(:new_attributes) {
#        skip("Add a hash of attributes valid for your model")
#      }
#
#      it "updates the requested plan" do
#        plan = Plan.create! valid_attributes
#        patch api_v1_plan_url(plan),
#              params: { plan: new_attributes }, headers: valid_headers, as: :json
#        plan.reload
#        skip("Add assertions for updated state")
#      end
#
#      it "renders a JSON response with the plan" do
#        plan = Plan.create! valid_attributes
#        patch api_v1_plan_url(plan),
#              params: { plan: new_attributes }, headers: valid_headers, as: :json
#        expect(response).to have_http_status(:ok)
#        expect(response.content_type).to match(a_string_including("application/json"))
#      end
#    end
#
#    context "with invalid parameters" do
#      it "renders a JSON response with errors for the plan" do
#        plan = Plan.create! valid_attributes
#        patch api_v1_plan_url(plan),
#              params: { plan: invalid_attributes }, headers: valid_headers, as: :json
#        expect(response).to have_http_status(:unprocessable_entity)
#        expect(response.content_type).to match(a_string_including("application/json"))
#      end
#    end
#  end
#
#  describe "DELETE /destroy" do
#    it "destroys the requested plan" do
#      plan = Plan.create! valid_attributes
#      expect {
#        delete api_v1_plan_url(plan), headers: valid_headers, as: :json
#      }.to change(Plan, :count).by(-1)
#    end
#  end
#end
#