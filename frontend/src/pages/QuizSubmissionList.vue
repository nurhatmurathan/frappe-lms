<template>
	<header
		class="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-3 py-2.5 sm:px-5"
	>
		<Breadcrumbs :items="breadcrumbs" />
	</header>
	<div v-if="submissions.data?.length" class="py-5 mx-5 md:w-3/4 md:mx-auto">
		<div class="mb-5 text-xl font-semibold">
			{{ submissions.data[0].quiz_title }}
		</div>
		<ListView
			:columns="quizColumns"
			:rows="submissions.data"
			row-key="name"
			:options="{ showTooltip: false, selectable: false }"
		>
			<ListHeader
				class="grid items-center p-2 mb-2 space-x-4 bg-gray-100 rounded"
			>
				<ListHeaderItem :item="item" v-for="item in quizColumns">
				</ListHeaderItem>
			</ListHeader>
			<ListRows>
				<router-link
					v-for="row in submissions.data"
					:to="{
						name: 'QuizSubmission',
						params: {
							submission: row.name,
						},
					}"
				>
					<ListRow :row="row" />
				</router-link>
			</ListRows>
		</ListView>
		<div class="flex justify-center my-5">
			<Button v-if="submissions.hasNextPage" @click="submissions.next()">
				{{ __('Загрузить еще') }}
			</Button>
		</div>
	</div>
</template>
<script setup>
import {
	Breadcrumbs,
	Button,
	createListResource,
	ListHeader,
	ListHeaderItem,
	ListRow,
	ListRows,
	ListView,
} from 'frappe-ui'
import { computed, inject, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const user = inject('$user')

onMounted(() => {
	if (!user.data?.is_instructor && !user.data?.is_moderator)
		router.push({ name: 'Courses' })
})

const props = defineProps({
	quizID: {
		type: String,
		required: true,
	},
})

const submissions = createListResource({
	doctype: 'LMS Quiz Submission',
	filters: {
		quiz: props.quizID,
	},
	fields: ['name', 'member_name', 'score', 'percentage', 'quiz_title'],
	orderBy: 'creation desc',
	auto: true,
})

const quizColumns = computed(() => {
	return [
		{
			label: __('Member'),
			key: 'member_name',
			width: 1,
		},
		{
			label: __('Score'),
			key: 'score',
			width: 1,
			align: 'center',
		},
		{
			label: __('Percentage'),
			key: 'percentage',
			width: 1,
			align: 'center',
		},
	]
})

const breadcrumbs = computed(() => {
	return [{ label: __('Quiz Submissions') }]
})
</script>
