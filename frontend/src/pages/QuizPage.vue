<template>
	<header
		class="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-3 py-2.5 sm:px-5"
	>
		<Breadcrumbs :items="breadcrumbs" />
	</header>
	<div class="py-10 mx-4 md:w-7/12 md:mx-auto">
		<Quiz :quizName="quizID" />
	</div>
</template>
<script setup>
import Quiz from '@/components/Quiz.vue'
import { updateDocumentTitle } from '@/utils'
import { Breadcrumbs, createResource } from 'frappe-ui'
import { computed, inject, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const user = inject('$user')
const router = useRouter()

onMounted(() => {
	if (!user.data) {
		router.push({ name: 'Courses' })
	}
})

const props = defineProps({
	quizID: {
		type: String,
		required: true,
	},
})

const title = createResource({
	url: 'frappe.client.get_value',
	params: {
		doctype: 'LMS Quiz',
		fieldname: 'title',
		filters: {
			name: props.quizID,
		},
	},
	auto: true,
})
const breadcrumbs = computed(() => {
	return [{ label: 'Отправка викторины' }, { label: title.data?.title }]
})

const pageMeta = computed(() => {
	return {
		title: title.data?.title,
		description: __('Quiz Submission'),
	}
})

updateDocumentTitle(pageMeta)
</script>
