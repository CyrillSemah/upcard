require 'rails_helper'

RSpec.describe CloudinaryService do
  describe '.upload' do
    let(:file) { fixture_file_upload('spec/fixtures/files/test_image.jpg', 'image/jpeg') }
    let(:upload_response) do
      {
        'secure_url' => 'https://res.cloudinary.com/test/image/upload/test_image.jpg',
        'public_id' => 'test_image'
      }
    end

    context 'when upload is successful' do
      before do
        allow(Cloudinary::Uploader).to receive(:upload).and_return(upload_response)
      end

      it 'returns the secure URL' do
        expect(described_class.upload(file)).to eq(upload_response['secure_url'])
      end

      it 'includes default options' do
        expect(Cloudinary::Uploader).to receive(:upload).with(
          file,
          hash_including(
            folder: Rails.env,
            resource_type: :auto,
            unique_filename: true
          )
        )
        described_class.upload(file)
      end

      it 'merges custom options' do
        custom_options = { folder: 'custom_folder' }
        expect(Cloudinary::Uploader).to receive(:upload).with(
          file,
          hash_including(custom_options)
        )
        described_class.upload(file, custom_options)
      end
    end

    context 'when upload fails' do
      before do
        allow(Cloudinary::Uploader).to receive(:upload).and_raise(StandardError.new('Upload failed'))
        allow(Rails.logger).to receive(:error)
      end

      it 'returns nil' do
        expect(described_class.upload(file)).to be_nil
      end

      it 'logs the error' do
        described_class.upload(file)
        expect(Rails.logger).to have_received(:error).with(/Upload failed/)
      end
    end

    context 'when file is nil' do
      it 'returns nil' do
        expect(described_class.upload(nil)).to be_nil
      end
    end
  end

  describe '.destroy' do
    let(:public_id) { 'test_image' }

    context 'when destroy is successful' do
      before do
        allow(Cloudinary::Uploader).to receive(:destroy).and_return('ok')
      end

      it 'returns true' do
        expect(described_class.destroy(public_id)).to be true
      end
    end

    context 'when destroy fails' do
      before do
        allow(Cloudinary::Uploader).to receive(:destroy).and_raise(StandardError.new('Destroy failed'))
        allow(Rails.logger).to receive(:error)
      end

      it 'returns false' do
        expect(described_class.destroy(public_id)).to be false
      end

      it 'logs the error' do
        described_class.destroy(public_id)
        expect(Rails.logger).to have_received(:error).with(/Destroy failed/)
      end
    end

    context 'when public_id is nil' do
      it 'returns nil' do
        expect(described_class.destroy(nil)).to be_nil
      end
    end
  end
end
