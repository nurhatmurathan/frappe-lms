<template>
	<Popover transition="default">
		<template #target="{ isOpen, togglePopover }" class="flex w-full">
			<slot v-bind="{ isOpen, togglePopover }"></slot>
		</template>
		<template #body>
			<div
				class="absolute max-w-lg px-4 mt-3 transform -translate-x-1/2 bg-white rounded-lg left-1/2 w-96 sm:px-0 lg:max-w-3xl"
			>
				<div
					class="p-3 overflow-hidden rounded-lg shadow-2xl ring-1 ring-black ring-opacity-5"
				>
					<div class="flex items-center justify-center space-x-2">
						<TextInput
							type="text"
							placeholder="поиск по ключевому слову"
							v-model="search"
							:debounce="300"
							class="flex-1"
						/>
						<FileUploader
							:fileTypes="['image/*']"
							:validateFile="validateFile"
							@success="(file) => saveImage(file)"
						>
							<template
								v-slot="{ file, progress, uploading, openFileSelector }"
							>
								<div class="">
									<Button @click="openFileSelector" :loading="uploading">
										{{
											uploading
												? `Загрузка ${progress}%`
												: 'Загрузить изображение'
										}}
									</Button>
								</div>
							</template>
						</FileUploader>
					</div>
					<div
						class="relative mt-2 grid w-[25.5rem] gap-2 bg-white lg:grid-cols-2"
					>
						<button
							v-for="image in images.data"
							:key="image.id"
							class="h-[50px] w-[200px] overflow-hidden rounded hover:opacity-80"
							@click="$emit('select', image.urls.raw)"
						>
							<img
								:src="
									image.urls.raw +
									'&w=200&h=50&fit=crop&crop=entropy,faces,focalpoint'
								"
							/>
						</button>
					</div>
					<div
						v-if="images.data"
						class="mt-2 text-sm text-center text-gray-500"
					>
						{{ __('Поиск изображений предоставлен') }}
						<a class="underline" target="_blank" href="https://unsplash.com">
							{{ __('Unsplash') }}
						</a>
					</div>
				</div>
			</div>
		</template>
	</Popover>
</template>
<script setup>
import {
	Button,
	createResource,
	FileUploader,
	Popover,
	TextInput,
} from 'frappe-ui'
import { ref, watch } from 'vue'

const search = ref(null)
const emit = defineEmits(['select'])

const images = createResource({
	url: 'lms.lms.api.get_unsplash_photos',
	makeParams: () => {
		return {
			keyword: search.value,
		}
	},
	auto: true,
	debounce: 500,
})

watch(
	() => search.value,
	() => {
		images.reload()
	},
)

const saveImage = (file) => {
	emit('select', file.file_url)
}

const validateFile = (file) => {
	let extension = file.name.split('.').pop().toLowerCase()
	if (!['jpg', 'jpeg', 'png'].includes(extension)) {
		return 'Only image file is allowed.'
	}
}
</script>
