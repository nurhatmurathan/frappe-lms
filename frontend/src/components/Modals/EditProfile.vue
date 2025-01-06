<template>
	<Dialog
		:options="{
			title: 'Редактировать профиль',
			size: 'xl',
			actions: [
				{
					label: 'Сохранить',
					variant: 'solid',
					onClick: (close) => saveProfile(close),
				},
			],
		}"
	>
		<template #body-content>
			<div>
				<FileUploader
					v-if="!profile.image"
					:fileTypes="['image/*']"
					:validateFile="validateFile"
					@success="(file) => saveImage(file)"
				>
					<template v-slot="{ file, progress, uploading, openFileSelector }">
						<div class="mb-4">
							<Button @click="openFileSelector" :loading="uploading">
								{{
									uploading
										? `Загрузка ${progress}%`
										: 'Загрузить изображение профиля'
								}}
							</Button>
						</div>
					</template>
				</FileUploader>
				<div v-else class="mb-4">
					<div class="mb-1 text-xs text-gray-600">
						{{ __('Изображение профиля') }}
					</div>
					<div class="flex items-center">
						<div class="p-2 mr-2 border rounded-md">
							<FileText class="h-5 w-5 stroke-1.5 text-gray-700" />
						</div>
						<div class="flex flex-col text-base">
							<span>
								{{ profile.image.file_name }}
							</span>
							<span class="mt-1 text-sm text-gray-500">
								{{ getFileSize(profile.image.file_size) }}
							</span>
						</div>
						<X
							@click="removeImage()"
							class="bg-gray-200 rounded-md cursor-pointer stroke-1.5 w-5 h-5 p-1 ml-4"
						/>
					</div>
				</div>
				<FormControl
					v-model="profile.first_name"
					:label="__('Имя')"
					class="mb-4"
				/>
				<FormControl
					v-model="profile.last_name"
					:label="__('Фамилия')"
					class="mb-4"
				/>
				<FormControl
					v-model="profile.headline"
					:label="__('Заголовок')"
					class="mb-4"
				/>

				<div class="mb-4">
					<div class="mb-1.5 text-sm text-gray-600">
						{{ __('Биография') }}
					</div>
					<TextEditor
						:fixedMenu="true"
						@change="(val) => (profile.bio = val)"
						:content="profile.bio"
						editorClass="prose-sm py-2 px-2 min-h-[200px] border-gray-300 hover:border-gray-400 rounded-md bg-gray-200"
					/>
				</div>
			</div>
		</template>
	</Dialog>
</template>
<script setup>
import {
	Dialog,
	FormControl,
	FileUploader,
	Button,
	createResource,
	TextEditor,
} from 'frappe-ui'
import { reactive, watch, defineModel } from 'vue'
import { FileText, X } from 'lucide-vue-next'
import { getFileSize, showToast } from '@/utils'

const reloadProfile = defineModel('reloadProfile')

const props = defineProps({
	profile: {
		type: Object,
		required: true,
	},
})

const profile = reactive({
	first_name: '',
	last_name: '',
	headline: '',
	bio: '',
	image: '',
})

const imageResource = createResource({
	url: 'lms.lms.api.get_file_info',
	makeParams(values) {
		return {
			file_url: values.image,
		}
	},
	auto: false,
	onSuccess(data) {
		profile.image = data
	},
})

const updateProfile = createResource({
	url: 'frappe.client.set_value',
	makeParams(values) {
		return {
			doctype: 'User',
			name: props.profile.data.name,
			fieldname: {
				user_image: profile.image.file_url,
				...profile,
			},
		}
	},
	onSuccess(data) {
		props.profile.data = data
	},
})

const saveProfile = (close) => {
	updateProfile.submit(
		{},
		{
			onSuccess() {
				close()
				reloadProfile.value.reload()
			},
			onError(err) {
				showToast('Error', err.messages?.[0] || err, 'x')
			},
		},
	)
}

const validateFile = (file) => {
	let extension = file.name.split('.').pop().toLowerCase()
	if (!['jpg', 'jpeg', 'png'].includes(extension)) {
		return 'Only image file is allowed.'
	}
}

const saveImage = (file) => {
	profile.image = file
}

const removeImage = () => {
	profile.image = null
}

watch(
	() => props.profile.data,
	(newVal) => {
		if (newVal) {
			profile.first_name = newVal.first_name
			profile.last_name = newVal.last_name
			profile.headline = newVal.headline
			profile.bio = newVal.bio
			if (newVal.user_image) imageResource.submit({ image: newVal.user_image })
		}
	},
)
</script>
