<template>
	<header
		class="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-3 py-2.5 sm:px-5"
	>
		<Breadcrumbs :items="breadcrumbs" />
		<router-link
			:to="{
				name: 'QuizForm',
				params: {
					quizID: 'new',
				},
			}"
		>
			<Button variant="solid">
				<template #prefix>
					<Plus class="w-4 h-4" />
				</template>
				{{ __('Новый тест') }}
			</Button>
		</router-link>
	</header>
	<div v-if="quizzes.data?.length" class="py-5 mx-5 md:w-3/4 md:mx-auto">
		<ListView
			:columns="quizColumns"
			:rows="quizzes.data"
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
					v-for="row in quizzes.data"
					:to="{
						name: 'QuizForm',
						params: {
							quizID: row.name,
						},
					}"
				>
					<ListRow :row="row" />
				</router-link>
			</ListRows>
		</ListView>
		<div class="flex justify-center my-5">
			<Button v-if="quizzes.hasNextPage" @click="quizzes.next()">
				{{ __('Загрузить еще') }}
			</Button>
		</div>
	</div>
	<div
		v-else
		class="w-3/4 p-5 mx-auto space-y-2 text-center text-gray-600 mt-52 md:w-1/2"
	>
		<BookOpen class="mx-auto text-gray-500 stroke-1 size-10" />
		<div class="text-xl font-medium">
			{{ __('Тесты не найдены') }}
		</div>
		<div class="leading-5">
			{{
				__(
					'Вы еще не создали ни одного теста. Чтобы создать новый тест, нажмите кнопку "Новый тест" выше.',
				)
			}}
		</div>
	</div>
</template>
<script setup>
import { updateDocumentTitle } from '@/utils'
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
import { BookOpen, Plus } from 'lucide-vue-next'
import { computed, inject, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const user = inject('$user')
const router = useRouter()

onMounted(() => {
	if (!user.data?.is_moderator && !user.data?.is_instructor) {
		router.push({ name: 'Courses' })
	}
})

const quizFilter = computed(() => {
	if (user.data?.is_moderator) return {}
	return {
		owner: user.data?.name,
	}
})

const quizzes = createListResource({
	doctype: 'LMS Quiz',
	filters: quizFilter,
	fields: ['name', 'title', 'passing_percentage', 'total_marks'],
	auto: true,
	cache: ['quizzes', user.data?.name],
	orderBy: 'modified desc',
})

const quizColumns = computed(() => {
	return [
		{
			label: __('Название'),
			key: 'title',
			width: 2,
		},
		{
			label: __('Общая оценка'),
			key: 'total_marks',
			width: 1,
			align: 'center',
		},
		{
			label: __('Проходной процент'),
			key: 'passing_percentage',
			width: 1,
			align: 'center',
		},
	]
})

const breadcrumbs = computed(() => {
	return [
		{
			label: __('Тесты'),
			route: {
				name: 'Quizzes',
			},
		},
	]
})

const pageMeta = computed(() => {
	return {
		title: __('Тесты'),
		description: __('Список тестов'),
	}
})

updateDocumentTitle(pageMeta)
</script>
