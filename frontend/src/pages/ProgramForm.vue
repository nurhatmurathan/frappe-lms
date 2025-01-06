<template>
	<header
		class="sticky top-0 z-10 flex flex-col md:flex-row md:items-center justify-between border-b bg-white px-3 py-2.5 sm:px-5"
	>
		<Breadcrumbs :items="breadbrumbs" />
		<Button variant="solid" @click="saveProgram()">
			{{ __('Сохранить') }}
		</Button>
	</header>
	<div v-if="program.doc" class="w-3/4 px-5 pt-5 mx-auto space-y-10">
		<FormControl v-model="program.doc.title" :label="__('Название')" />

		<!-- Courses -->
		<div>
			<div class="flex items-center justify-between mb-2">
				<div class="text-lg font-semibold">
					{{ __('Курсы программы') }}
				</div>
				<Button
					@click="
						() => {
							currentForm = 'course'
							showDialog = true
						}
					"
				>
					<template #prefix>
						<Plus class="w-4 h-4" />
					</template>
					{{ __('Добавить') }}
				</Button>
			</div>

			<ListView
				:columns="courseColumns"
				:rows="program.doc.program_courses"
				row-key="name"
				:options="{
					showTooltip: false,
				}"
			>
				<ListHeader
					class="grid items-center p-2 mb-2 space-x-4 bg-gray-100 rounded"
				>
					<ListHeaderItem :item="item" v-for="item in courseColumns" />
				</ListHeader>
				<ListRows>
					<Draggable
						:list="program.doc.program_courses"
						item-key="name"
						group="items"
						@end="updateOrder"
						class="cursor-move"
					>
						<template #item="{ element: row }">
							<ListRow :row="row" />
						</template>
					</Draggable>
				</ListRows>
				<ListSelectBanner>
					<template #actions="{ unselectAll, selections }">
						<div class="flex gap-2">
							<Button
								variant="ghost"
								@click="remove(selections, unselectAll, 'program_courses')"
							>
								<Trash2 class="h-4 w-4 stroke-1.5" />
							</Button>
						</div>
					</template>
				</ListSelectBanner>
			</ListView>
		</div>

		<!-- Members -->
		<div>
			<div class="flex items-center justify-between mb-2">
				<div class="text-lg font-semibold">
					{{ __('Участники программы') }}
				</div>
				<Button
					@click="
						() => {
							currentForm = 'member'
							showDialog = true
						}
					"
				>
					<template #prefix>
						<Plus class="w-4 h-4" />
					</template>
					{{ __('Добавить') }}
				</Button>
			</div>

			<ListView
				:columns="memberColumns"
				:rows="program.doc.program_members"
				row-key="name"
				:options="{
					showTooltip: false,
				}"
			>
				<ListHeader
					class="grid items-center p-2 mb-2 space-x-4 bg-gray-100 rounded"
				>
					<ListHeaderItem :item="item" v-for="item in memberColumns" />
				</ListHeader>
				<ListRows>
					<ListRow :row="row" v-for="row in program.doc.program_members" />
				</ListRows>
				<ListSelectBanner>
					<template #actions="{ unselectAll, selections }">
						<div class="flex gap-2">
							<Button
								variant="ghost"
								@click="remove(selections, unselectAll, 'program_members')"
							>
								<Trash2 class="h-4 w-4 stroke-1.5" />
							</Button>
						</div>
					</template>
				</ListSelectBanner>
			</ListView>
		</div>
	</div>

	<Dialog
		v-model="showDialog"
		:options="{
			title:
				currentForm == 'course'
					? __('Новый курс программы')
					: __('Новый участник программы'),
			actions: [
				{
					label: __('Добавить'),
					variant: 'solid',
					onClick: () =>
						currentForm == 'course'
							? addProgramCourse(close)
							: addProgramMember(close),
				},
			],
		}"
	>
		<template #body-content>
			<Link
				v-if="currentForm == 'course'"
				v-model="course"
				doctype="LMS Course"
				:filters="{
					disable_self_learning: 1,
				}"
				:label="__('Курс программы')"
				:description="
					__(
						'Только курсы, для которых отключено самостоятельное обучение, могут быть добавлены в программу.',
					)
				"
			/>

			<Link
				v-if="currentForm == 'member'"
				v-model="member"
				doctype="User"
				:filters="{
					ignore_user_type: 1,
				}"
				:label="__('Участник программы')"
			/>
		</template>
	</Dialog>
</template>
<script setup>
import Link from '@/components/Controls/Link.vue'
import { showToast } from '@/utils/'
import {
	Breadcrumbs,
	Button,
	call,
	createDocumentResource,
	Dialog,
	FormControl,
	ListHeader,
	ListHeaderItem,
	ListRow,
	ListRows,
	ListSelectBanner,
	ListView,
} from 'frappe-ui'
import { Plus, Trash2 } from 'lucide-vue-next'
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import Draggable from 'vuedraggable'

const showDialog = ref(false)
const currentForm = ref(null)
const course = ref(null)
const member = ref(null)
const router = useRouter()

const props = defineProps({
	programName: {
		type: String,
		required: true,
	},
})

const program = createDocumentResource({
	doctype: 'LMS Program',
	name: props.programName,
	auto: true,
	cache: ['program', props.programName],
})

const addProgramCourse = () => {
	program.setValue.submit(
		{
			program_courses: [
				...program.doc.program_courses,
				{ course: course.value },
			],
		},
		{
			onSuccess(data) {
				showDialog.value = false
				course.value = null
				showToast(__('Успех'), __('Курс добавлен в программу'), 'check')
				program.reload()
			},
			onError(err) {
				showToast('Ошибка', err.messages?.[0] || err, 'x')
			},
		},
	)
}

const addProgramMember = () => {
	program.setValue.submit(
		{
			program_members: [
				...program.doc.program_members,
				{ member: member.value },
			],
		},
		{
			onSuccess(data) {
				showDialog.value = false
				member.value = null
				showToast(__('Успех'), __('Участник добавлен в программу'), 'check')
				program.reload()
			},
			onError(err) {
				showToast('Ошибка', err.messages?.[0] || err, 'x')
			},
		},
	)
}

const remove = (selections, unselectAll, doctype) => {
	selections = Array.from(selections)
	program.setValue.submit(
		{
			[doctype]: program.doc[doctype].filter(
				(row) => !selections.includes(row.name),
			),
		},
		{
			onSuccess(data) {
				unselectAll()
				showToast(__('Успех'), __('Элементы успешно удалены'), 'check')
				program.reload()
			},
			onError(err) {
				showToast('Ошибка', err.messages?.[0] || err, 'x')
			},
		},
	)
}

const updateOrder = (e) => {
	let sourceIdx = e.from.dataset.idx
	let targetIdx = e.to.dataset.idx
	let courses = program.doc.program_courses
	courses.splice(targetIdx, 0, courses.splice(sourceIdx, 1)[0])

	courses.forEach((course, index) => {
		course.idx = index + 1
	})

	program.setValue.submit(
		{
			program_courses: courses,
		},
		{
			onSuccess(data) {
				showToast(__('Успех'), __('Курс успешно перемещен'), 'check')
				program.reload()
			},
			onError(err) {
				showToast('Ошибка', err.messages?.[0] || err, 'x')
			},
		},
	)
}

const saveProgram = () => {
	call('frappe.model.rename_doc.update_document_title', {
		doctype: 'LMS Program',
		docname: program.doc.name,
		name: program.doc.title,
	}).then((data) => {
		router.push({ name: 'ProgramForm', params: { programName: data } })
	})
}

const courseColumns = computed(() => {
	return [
		{
			label: 'Название',
			key: 'course_title',
			width: 3,
		},
		{
			label: 'ID',
			key: 'course',
			width: 3,
		},
	]
})

const memberColumns = computed(() => {
	return [
		{
			label: 'Участник',
			key: 'member',
			width: 3,
			align: 'left',
		},
		{
			label: 'Полное имя',
			key: 'full_name',
			width: 3,
			align: 'left',
		},
		{
			label: 'Прогресс (%)',
			key: 'progress',
			width: 3,
			align: 'right',
		},
	]
})

const breadbrumbs = computed(() => {
	return [
		{
			label: 'Программы',
			route: { name: 'Programs' },
		},
		{
			label:
				props.programName === 'new' ? 'Новая программа' : props.programName,
		},
	]
})
</script>
