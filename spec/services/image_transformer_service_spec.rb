require 'rails_helper'

RSpec.describe ImageTransformerService do
  let(:cloudinary_url) { 'https://res.cloudinary.com/demo/image/upload/sample.jpg' }
  let(:external_url) { 'https://example.com/image.jpg' }

  describe '.template_preview' do
    it 'transforms template preview images with correct parameters' do
      allow(Cloudinary::Utils).to receive(:cloudinary_url).and_return('transformed_url')
      
      result = described_class.template_preview(cloudinary_url)
      
      expect(Cloudinary::Utils).to have_received(:cloudinary_url).with(
        'sample',
        hash_including(
          width: 300,
          height: 200,
          crop: :fill,
          quality: :auto,
          fetch_format: :auto
        )
      )
    end
  end

  describe '.template_background' do
    it 'transforms template background images with correct parameters' do
      allow(Cloudinary::Utils).to receive(:cloudinary_url).and_return('transformed_url')
      
      result = described_class.template_background(cloudinary_url)
      
      expect(Cloudinary::Utils).to have_received(:cloudinary_url).with(
        'sample',
        hash_including(
          width: 1200,
          crop: :scale,
          quality: :auto,
          fetch_format: :auto
        )
      )
    end
  end

  describe '.card_cover' do
    it 'transforms card cover images with correct parameters' do
      allow(Cloudinary::Utils).to receive(:cloudinary_url).and_return('transformed_url')
      
      result = described_class.card_cover(cloudinary_url)
      
      expect(Cloudinary::Utils).to have_received(:cloudinary_url).with(
        'sample',
        hash_including(
          width: 800,
          crop: :scale,
          quality: :auto,
          fetch_format: :auto,
          effect: "auto_contrast"
        )
      )
    end
  end

  describe '.card_thumbnail' do
    it 'transforms card thumbnail images with correct parameters' do
      allow(Cloudinary::Utils).to receive(:cloudinary_url).and_return('transformed_url')
      
      result = described_class.card_thumbnail(cloudinary_url)
      
      expect(Cloudinary::Utils).to have_received(:cloudinary_url).with(
        'sample',
        hash_including(
          width: 200,
          height: 150,
          crop: :thumb,
          gravity: :auto,
          quality: :auto,
          fetch_format: :auto
        )
      )
    end
  end

  describe 'error handling' do
    it 'returns nil for nil URLs' do
      expect(described_class.template_preview(nil)).to be_nil
    end

    it 'returns nil for empty URLs' do
      expect(described_class.template_preview('')).to be_nil
    end
  end

  describe 'URL handling' do
    it 'correctly extracts public_id from Cloudinary URLs' do
      transformed_url = described_class.template_preview(cloudinary_url)
      expect(Cloudinary::Utils).to have_received(:cloudinary_url).with('sample', anything)
    end

    it 'handles external URLs' do
      transformed_url = described_class.template_preview(external_url)
      expect(Cloudinary::Utils).to have_received(:cloudinary_url).with(external_url, anything)
    end
  end
end
