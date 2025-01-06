<template>
	<header
		class="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-3 py-2.5 sm:px-5"
	>
		<Breadcrumbs class="h-7" :items="breadcrumbs" />
	</header>
	<div
		v-if="
			readyToRender &&
			(enrollment.data?.length ||
				user.data?.is_moderator ||
				user.data?.is_instructor)
		"
	>
		<iframe :src="chapter.doc.launch_file" class="w-full h-screen" />
	</div>
	<div v-else-if="!enrollment.data?.length">
		<div class="px-5 pt-10 pb-10 text-center md:px-0">
			<div class="text-center">
				<div class="mb-4">
					{{
						__(
							'Вы не записаны на этот курс. Пожалуйста, запишитесь, чтобы получить доступ к этому уроку.',
						)
					}}
				</div>
				<Button variant="solid" @click="enrollStudent()">
					{{ __('Начать обучение') }}
				</Button>
			</div>
		</div>
	</div>
</template>
<script setup>
import { useSidebar } from '@/stores/sidebar'
import { updateDocumentTitle } from '@/utils'
import {
	Breadcrumbs,
	Button,
	call,
	createDocumentResource,
	createListResource,
	createResource,
} from 'frappe-ui'
import { computed, inject, onBeforeMount, ref } from 'vue'

const sidebarStore = useSidebar()
const user = inject('$user')
const readyToRender = ref(false)

const props = defineProps({
	courseName: {
		type: String,
		required: true,
	},
	chapterName: {
		type: String,
		required: true,
	},
})

onBeforeMount(() => {
	sidebarStore.isSidebarCollapsed = true
	setupSCORMAPI()
})

const chapter = createDocumentResource({
	doctype: 'Course Chapter',
	name: props.chapterName,
	auto: true,
	cache: ['chapter', props.chapterName],
	onSuccess(data) {
		progress.submit()
	},
})

const enrollment = createListResource({
	doctype: 'LMS Enrollment',
	fields: ['member', 'course'],
	filters: {
		course: props.courseName,
		member: user.data?.name,
	},
	auto: true,
	cache: ['enrollments', props.courseName, user.data?.name],
})

const getDataFromLMS = (key) => {
	if (key == 'cmi.core.lesson_status') {
		if (progress.data?.status == 'Complete') {
			return 'passed'
		}
		return 'incomplete'
	}
	return ''
}

const saveDataToLMS = (key, value) => {
	if (key == 'cmi.core.lesson_status' && value == 'passed') {
		saveProgress()
	}
}

const saveProgress = () => {
	call('lms.lms.doctype.course_lesson.course_lesson.save_progress', {
		lesson: chapter.doc.lessons[0].lesson,
		course: props.courseName,
	})
}

const progress = createResource({
	url: 'frappe.client.get_value',
	makeParams(values) {
		return {
			doctype: 'LMS Course Progress',
			fieldname: 'status',
			filters: {
				member: user.data?.name,
				lesson: chapter.doc.lessons[0].lesson,
				chapter: chapter.doc.name,
				course: chapter.doc?.course,
			},
		}
	},
	onSuccess(data) {
		readyToRender.value = true
	},
})

const enrollStudent = () => {
	enrollment.insert.submit(
		{
			course: props.courseName,
			member: user.data?.name,
		},
		{
			onSuccess(data) {
				window.location.reload()
			},
		},
	)
}

const setupSCORMAPI = () => {
	window.API_1484_11 = {
		Initialize: () => 'true',
		Terminate: () => 'true',
		GetValue: (key) => {
			console.log(`GET: ${key}`)
			return getDataFromLMS(key)
		},
		SetValue: (key, value) => {
			console.log(`SET: ${key} to value: ${value}`)

			saveDataToLMS(key, value)
			return 'true'
		},
		Commit: () => 'true',
		GetLastError: () => '0',
		GetErrorString: () => '',
		GetDiagnostic: () => '',
	}
	window.API = {
		LMSInitialize: () => 'true',
		LMSFinish: () => 'true',
		LMSGetValue: (key) => {
			console.log(`GET: ${key}`)
			return getDataFromLMS(key)
		},
		LMSSetValue: (key, value) => {
			console.log(`SET: ${key} to value: ${value}`)
			saveDataToLMS(key, value)
			return 'true'
		},
		LMSCommit: () => 'true',
		LMSGetLastError: () => '0',
		LMSGetErrorString: () => '',
		LMSGetDiagnostic: () => '',
	}
}

const breadcrumbs = computed(() => {
	return [
		{
			label: 'Courses',
			route: { name: 'Courses' },
		},
		{
			label: chapter.doc?.course_title,
			route: { name: 'CourseDetail', params: { courseName: props.courseName } },
		},
		{
			label: chapter.doc?.title,
		},
	]
})

const pageMeta = computed(() => {
	return {
		title: chapter?.doc?.title,
		description: __('Это глава курса {0}').format(chapter?.doc?.course_title),
	}
})

updateDocumentTitle(pageMeta)
</script>
