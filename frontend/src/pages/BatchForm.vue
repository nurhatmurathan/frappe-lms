<template>
	<div class="">
		<header
			class="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-3 py-2.5 sm:px-5"
		>
			<Breadcrumbs class="h-7" :items="breadcrumbs" />
			<Button variant="solid" @click="saveBatch()">
				{{ __('Сохранить') }}
			</Button>
		</header>
		<div class="w-1/2 py-5 mx-auto">
			<div class="">
				<div class="mb-4 text-lg font-semibold">
					{{ __('Детали') }}
				</div>
				<div class="grid grid-cols-2 gap-10 mb-4 space-y-2">
					<div>
						<FormControl
							v-model="batch.title"
							:label="__('Название')"
							:required="true"
						/>
					</div>
					<div class="flex flex-col space-y-2">
						<FormControl
							v-model="batch.published"
							type="checkbox"
							:label="__('Опубликовано')"
						/>
						<FormControl
							v-model="batch.allow_self_enrollment"
							type="checkbox"
							:label="__('Разрешить самостоятельную регистрацию')"
						/>
					</div>
				</div>
			</div>
			<div class="mb-4">
				<div class="mb-2 text-xs text-gray-600">
					{{ __('Мета изображение') }}
				</div>
				<FileUploader
					v-if="!batch.image"
					:fileTypes="['image/*']"
					:validateFile="validateFile"
					@success="(file) => saveImage(file)"
				>
					<template v-slot="{ file, progress, uploading, openFileSelector }">
						<div class="flex items-center">
							<div class="px-20 py-5 border rounded-md w-fit">
								<Image class="text-gray-700 stroke-1 size-5" />
							</div>
							<div class="ml-4">
								<Button @click="openFileSelector">
									{{ __('Загрузить') }}
								</Button>
								<div class="mt-2 text-sm text-gray-600">
									{{
										__(
											'Появляется, когда URL партии делится на любой онлайн платформе',
										)
									}}
								</div>
							</div>
						</div>
					</template>
				</FileUploader>
				<div v-else class="mb-4">
					<div class="flex items-center">
						<img :src="batch.image.file_url" class="w-40 border rounded-md" />
						<div class="ml-4">
							<Button @click="removeImage()">
								{{ __('Удалить') }}
							</Button>
							<div class="mt-2 text-sm text-gray-600">
								{{
									__(
										'Появляется, когда URL партии делится на любой онлайн платформе',
									)
								}}
							</div>
						</div>
					</div>
				</div>
			</div>
			<MultiSelect
				v-model="instructors"
				doctype="User"
				:label="__('Инструкторы')"
				:required="true"
				:filters="{ ignore_user_type: 1 }"
			/>
			<div class="mb-4">
				<FormControl
					v-model="batch.description"
					:label="__('Описание')"
					type="textarea"
					class="my-4"
					:placeholder="__('Краткое описание партии')"
					:required="true"
				/>
				<div>
					<label class="block mb-1 text-sm text-gray-600">
						{{ __('Детали партии') }}
						<span class="text-red-500">*</span>
					</label>
					<TextEditor
						:content="batch.batch_details"
						@change="(val) => (batch.batch_details = val)"
						:editable="true"
						:fixedMenu="true"
						editorClass="prose-sm max-w-none border-b border-x bg-gray-100 rounded-b-md py-1 px-2 min-h-[7rem] mb-4"
					/>
				</div>
			</div>
			<div class="mb-4">
				<div class="mb-4 text-lg font-semibold">
					{{ __('Дата и время') }}
				</div>
				<div class="grid grid-cols-2 gap-10">
					<div>
						<FormControl
							v-model="batch.start_date"
							:label="__('Дата начала')"
							type="date"
							class="mb-4"
							:required="true"
						/>
						<FormControl
							v-model="batch.end_date"
							:label="__('Дата окончания')"
							type="date"
							class="mb-4"
							:required="true"
						/>
					</div>
					<div>
						<FormControl
							v-model="batch.start_time"
							:label="__('Время начала')"
							type="time"
							class="mb-4"
							:required="true"
						/>
						<FormControl
							v-model="batch.end_time"
							:label="__('Время окончания')"
							type="time"
							class="mb-4"
							:required="true"
						/>
						<FormControl
							v-model="batch.timezone"
							:label="__('Часовой пояс')"
							type="text"
							:placeholder="__('Пример: IST (+5:30)')"
							class="mb-4"
							:required="true"
						/>
					</div>
				</div>
			</div>
			<div class="mb-4">
				<div class="mb-4 text-lg font-semibold">
					{{ __('Настройки') }}
				</div>
				<div class="grid grid-cols-2 gap-10">
					<div>
						<FormControl
							v-model="batch.seat_count"
							:label="__('Количество мест')"
							type="number"
							class="mb-4"
							:placeholder="__('Количество доступных мест')"
						/>
						<FormControl
							v-model="batch.evaluation_end_date"
							:label="__('Дата окончания оценки')"
							type="date"
							class="mb-4"
						/>
					</div>
					<div>
						<FormControl
							v-model="batch.medium"
							type="select"
							:options="[
								{
									label: 'Онлайн',
									value: 'Online',
								},
								{
									label: 'Офлайн',
									value: 'Offline',
								},
							]"
							:label="__('Среда')"
							class="mb-4"
						/>
						<Link
							doctype="LMS Category"
							:label="__('Категория')"
							v-model="batch.category"
						/>
					</div>
				</div>
			</div>

			<div class="">
				<div class="mb-4 text-lg font-semibold">
					{{ __('Оплата') }}
				</div>
				<div>
					<FormControl
						v-model="batch.paid_batch"
						type="checkbox"
						:label="__('Платная партия')"
					/>
					<FormControl
						v-model="batch.amount"
						:label="__('Сумма')"
						type="number"
						class="my-4"
					/>
					<Link
						doctype="Currency"
						v-model="batch.currency"
						:filters="{ enabled: 1 }"
						:label="__('Валюта')"
					/>
				</div>
			</div>
		</div>
	</div>
</template>
<script setup>
import Link from '@/components/Controls/Link.vue'
import MultiSelect from '@/components/Controls/MultiSelect.vue'
import { capture } from '@/telemetry'
import { showToast } from '@/utils'
import {
	Breadcrumbs,
	Button,
	FileUploader,
	FormControl,
	TextEditor,
	createResource,
} from 'frappe-ui'
import { Image } from 'lucide-vue-next'
import {
	computed,
	inject,
	onBeforeUnmount,
	onMounted,
	reactive,
	ref,
} from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const user = inject('$user')

const props = defineProps({
	batchName: {
		type: String,
		required: true,
	},
})

const batch = reactive({
	title: '',
	published: false,
	description: '',
	batch_details: '',
	start_date: '',
	end_date: '',
	start_time: '',
	end_time: '',
	timezone: '',
	evaluation_end_date: '',
	seat_count: '',
	medium: '',
	category: '',
	allow_self_enrollment: false,
	image: null,
	paid_batch: false,
	currency: '',
	amount: 0,
})

const instructors = ref([])

onMounted(() => {
	if (!user.data) window.location.href = '/login'
	if (props.batchName != 'new') {
		batchDetail.reload()
	} else {
		capture('batch_form_opened')
	}
	window.addEventListener('keydown', keyboardShortcut)
})

const keyboardShortcut = (e) => {
	if (
		e.key === 's' &&
		(e.ctrlKey || e.metaKey) &&
		!e.target.classList.contains('ProseMirror')
	) {
		saveBatch()
		e.preventDefault()
	}
}

onBeforeUnmount(() => {
	window.removeEventListener('keydown', keyboardShortcut)
})

const newBatch = createResource({
	url: 'frappe.client.insert',
	makeParams(values) {
		return {
			doc: {
				doctype: 'LMS Batch',
				meta_image: batch.image?.file_url,
				instructors: instructors.value.map((instructor) => ({
					instructor: instructor,
				})),
				...batch,
			},
		}
	},
})

const batchDetail = createResource({
	url: 'frappe.client.get',
	makeParams(values) {
		return {
			doctype: 'LMS Batch',
			name: props.batchName,
		}
	},
	onSuccess(data) {
		Object.keys(data).forEach((key) => {
			if (key == 'instructors') {
				data.instructors.forEach((instructor) => {
					instructors.value.push(instructor.instructor)
				})
			} else if (['start_time', 'end_time'].includes(key)) {
				let [hours, minutes, seconds] = data[key].split(':')
				hours = hours.length == 1 ? '0' + hours : hours
				batch[key] = `${hours}:${minutes}`
			} else if (Object.hasOwn(batch, key)) batch[key] = data[key]
		})
		let checkboxes = ['published', 'paid_batch', 'allow_self_enrollment']
		for (let idx in checkboxes) {
			let key = checkboxes[idx]
			batch[key] = batch[key] ? true : false
		}
		if (data.meta_image) imageResource.reload({ image: data.meta_image })
	},
})

const editBatch = createResource({
	url: 'frappe.client.set_value',
	makeParams(values) {
		return {
			doctype: 'LMS Batch',
			name: props.batchName,
			fieldname: {
				meta_image: batch.image?.file_url,
				instructors: instructors.value.map((instructor) => ({
					instructor: instructor,
				})),
				...batch,
			},
		}
	},
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
		batch.image = data
	},
})

const saveBatch = () => {
	if (batchDetail.data) {
		editBatchDetails()
	} else {
		createNewBatch()
	}
}

const createNewBatch = () => {
	newBatch.submit(
		{},
		{
			onSuccess(data) {
				capture('batch_created')
				router.push({
					name: 'BatchDetail',
					params: {
						batchName: data.name,
					},
				})
			},
			onError(err) {
				showToast('Error', err.messages?.[0] || err, 'x')
			},
		},
	)
}

const editBatchDetails = () => {
	editBatch.submit(
		{},
		{
			onSuccess(data) {
				router.push({
					name: 'BatchDetail',
					params: {
						batchName: data.name,
					},
				})
			},
			onError(err) {
				showToast('Error', err.messages?.[0] || err, 'x')
			},
		},
	)
}

const saveImage = (file) => {
	batch.image = file
}

const removeImage = () => {
	batch.image = null
}

const validateFile = (file) => {
	let extension = file.name.split('.').pop().toLowerCase()
	if (!['jpg', 'jpeg', 'png'].includes(extension)) {
		return 'Only image file is allowed.'
	}
}

const breadcrumbs = computed(() => {
	let crumbs = [
		{
			label: 'Batches',
			route: {
				name: 'Batches',
			},
		},
	]
	if (batchDetail.data) {
		crumbs.push({
			label: batchDetail.data.title,
			route: {
				name: 'BatchDetail',
				params: {
					batchName: props.batchName,
				},
			},
		})
	}
	crumbs.push({
		label: props.batchName == 'new' ? 'New Batch' : 'Edit Batch',
		route: { name: 'BatchForm', params: { batchName: props.batchName } },
	})
	return crumbs
})
</script>
