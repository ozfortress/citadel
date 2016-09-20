require 'rails_helper'

describe Forums::Posts::EditingService do
  let(:user) { create(:user) }
  let(:post) { create(:forums_post) }
  let(:creator) { post.created_by }

  it 'succesfully edits a post' do
    subject.call(user, post, content: 'Foo')

    expect(post).to_not be_changed
    expect(post.created_by).to eq(creator)
    expect(post.content).to eq('Foo')
  end

  it 'creates post edit history' do
    subject.call(user, post, content: 'Foo')

    expect(post.edits.count).to eq(1)
    edit = post.edits.first
    expect(edit.created_by).to eq(user)
    expect(edit.content).to eq('Foo')
  end

  it 'handles invalid data' do
    subject.call(user, post, content: '')

    expect(post).to be_invalid
    expect(post.edits).to be_empty
  end
end
