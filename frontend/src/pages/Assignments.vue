<template>
	<header
		class="sticky top-0 z-10 flex items-center justify-between border-b bg-white px-3 py-2.5 sm:px-5"
	>
		<Breadcrumbs :items="breadcrumbs" />
		<router-link
			:to="{
				name: 'AssignmentForm',
				params: {
					assignmentID: 'new',
				},
			}"
		>
			<Button variant="solid">
				<template #prefix>
					<Plus class="w-4 h-4" />
				</template>
				{{ __('Новый') }}
			</Button>
		</router-link>
	</header>

	<div class="py-5 mx-5 md:w-3/4 md:mx-auto">
		<div class="grid grid-cols-3 gap-5 mb-5">
			<FormControl
				v-model="titleFilter"
				:placeholder="__('Поиск по названию')"
			/>
			<FormControl
				v-model="typeFilter"
				type="select"
				:options="assignmentTypes"
				:placeholder="__('Тип')"
			/>
		</div>
		<ListView
			v-if="assignments.data?.length"
			:columns="assignmentColumns"
			:rows="assignments.data"
			row-key="name"
			:options="{
				showTooltip: false,
				selectable: false,
				getRowRoute: (row) => ({
					name: 'AssignmentForm',
					params: {
						assignmentID: row.name,
					},
				}),
			}"
		>
		</ListView>
		<div
			v-else
			class="w-3/4 p-5 mx-auto space-y-2 text-center text-gray-600 mt-52 md:w-1/2"
		>
			<Pencil class="mx-auto text-gray-500 stroke-1 size-10" />
			<div class="text-xl font-medium">
				{{ __('Задания не найдены') }}
			</div>
			<div class="leading-5">
				{{
					__(
						'Вы еще не создали ни одного задания. Чтобы создать новое задание, нажмите кнопку "Новый" выше.',
					)
				}}
			</div>
		</div>
		<div
			v-if="assignments.data && assignments.hasNextPage"
			class="flex justify-center my-5"
		>
			<Button @click="assignments.next()">
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
	FormControl,
	ListView,
} from 'frappe-ui'
import { Pencil, Plus } from 'lucide-vue-next'
import { computed, inject, onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'

const user = inject('$user')
const dayjs = inject('$dayjs')
const titleFilter = ref('')
const typeFilter = ref('')
const router = useRouter()

onMounted(() => {
	if (!user.data?.is_moderator && !user.data?.is_instructor) {
		router.push({ name: 'Courses' })
	}

	titleFilter.value = router.currentRoute.value.query.title
	typeFilter.value = router.currentRoute.value.query.type
})

watch([titleFilter, typeFilter], () => {
	router.push({
		query: {
			title: titleFilter.value,
			type: typeFilter.value,
		},
	})
	reloadAssignments()
})

const reloadAssignments = () => {
	assignments.update({
		filters: assignmentFilter.value,
	})
	assignments.reload()
}

const assignmentFilter = computed(() => {
	let filters = {}
	if (titleFilter.value) {
		filters.title = ['like', `%${titleFilter.value}%`]
	}
	if (typeFilter.value) {
		filters.type = typeFilter.value
	}
	if (!user.data?.is_moderator) {
		filters.owner = user.data?.email
	}
	return filters
})

const assignments = createListResource({
	doctype: 'LMS Assignment',
	fields: ['name', 'title', 'type', 'creation'],
	orderBy: 'modified desc',
	cache: ['assignments'],
	transform(data) {
		return data.map((row) => {
			return {
				...row,
				creation: dayjs(row.creation).fromNow(),
			}
		})
	},
})

const assignmentColumns = computed(() => {
	return [
		{
			label: __('Title'),
			key: 'title',
			width: 2,
		},
		{
			label: __('Type'),
			key: 'type',
			width: 1,
			align: 'left',
		},
		{
			label: __('Created'),
			key: 'creation',
			width: 1,
			align: 'center',
		},
	]
})

const assignmentTypes = computed(() => {
	let types = ['', 'Document', 'Image', 'PDF', 'URL', 'Text']
	return types.map((type) => {
		return {
			label: __(type),
			value: type,
		}
	})
})

const breadcrumbs = computed(() => [
	{
		label: 'Assignments',
		route: { name: 'Assignments' },
	},
])
</script>
